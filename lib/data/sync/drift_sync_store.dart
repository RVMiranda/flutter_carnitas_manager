import 'dart:convert';
import 'package:drift/drift.dart';
import '../local/database/app_database.dart';
import 'conflict_resolver.dart';
import 'sync_models.dart';

class DriftSyncStore {
  DriftSyncStore(this.db, {this.conflicts = const ConflictResolver()});
  final AppDatabase db;
  final ConflictResolver conflicts;

  Future<void> bindScope(String scope) async {
    await db.customStatement(
      'INSERT OR IGNORE INTO sync_identity(id,owner) VALUES(1,?)',
      [scope],
    );
    final owner = await db
        .customSelect('SELECT owner FROM sync_identity WHERE id=1')
        .getSingle();
    if (owner.read<String>('owner') != scope) {
      throw const SyncContractException();
    }
  }

  Future<void> trace(String? operation, String event, int now) =>
      db.customStatement(
        'INSERT INTO sync_trace(operation_id,event,at) VALUES(?,?,?)',
        [operation, event, now],
      );

  Future<void> recover(int now) => db.transaction(() async {
    final rows = await (db.select(
      db.syncQueueTable,
    )..where((t) => t.status.equals('processing'))).get();
    for (final row in rows) {
      await (db.update(db.syncQueueTable)..where((t) => t.id.equals(row.id)))
          .write(const SyncQueueTableCompanion(status: Value('pending')));
      await trace(row.id, 'recovered', now);
    }
  });

  Future<int> cursor(String scope) async =>
      (await db
              .customSelect(
                'SELECT cursor FROM sync_checkpoint WHERE scope=?',
                variables: [Variable(scope)],
              )
              .getSingleOrNull())
          ?.read<int>('cursor') ??
      0;

  Future<int> baseVersion(String id) async =>
      (await db
              .customSelect(
                'SELECT base_version FROM sync_operation_state WHERE operation_id=?',
                variables: [Variable(id)],
              )
              .getSingleOrNull())
          ?.read<int>('base_version') ??
      0;

  Future<List<SyncQueueTableData>> due(int now) async {
    // Join BEFORE limit: a backed-off head must not starve newer ready work.
    final ids = await db
        .customSelect(
          "SELECT q.id FROM sync_queue q JOIN sync_operation_state s ON s.operation_id=q.id WHERE q.status='pending' AND s.next_attempt_at<=? AND NOT EXISTS (SELECT 1 FROM sync_queue older WHERE older.entity=q.entity AND older.entity_id=q.entity_id AND older.status<>'completed' AND NOT EXISTS(SELECT 1 FROM critical_operations c WHERE c.operation_id=older.id AND c.state='rejected' AND c.acknowledged=1) AND (older.created_at<q.created_at OR (older.created_at=q.created_at AND older.rowid<q.rowid))) ORDER BY q.created_at,q.rowid LIMIT 50",
          variables: [Variable(now)],
        )
        .get();
    if (ids.isEmpty) return [];
    final rows =
        await (db.select(db.syncQueueTable)
              ..where((t) => t.id.isIn(ids.map((r) => r.read<String>('id'))))
              ..orderBy([
                (t) => OrderingTerm(expression: t.createdAt),
                (t) => OrderingTerm(expression: t.id),
              ]))
            .get();
    final byId = {for (final row in rows) row.id: row};
    return ids.map((id) => byId[id.read<String>('id')]!).toList();
  }

  Future<bool> claim(String id, int now) => db.transaction(() async {
    final count =
        await (db.update(
          db.syncQueueTable,
        )..where((t) => t.id.equals(id) & t.status.equals('pending'))).write(
          SyncQueueTableCompanion(
            status: const Value('processing'),
            lastAttemptAt: Value(now),
          ),
        );
    if (count == 1) await trace(id, 'processing', now);
    return count == 1;
  });

  Future<void> finish(
    SyncQueueTableData op, {
    required String status,
    required int now,
    String? code,
    int? nextAttempt,
    int? version,
    Map<String, Object?>? receipt,
    bool rejectionKnown = false,
  }) => db.transaction(() async {
    await (db.update(
      db.syncQueueTable,
    )..where((t) => t.id.equals(op.id))).write(
      SyncQueueTableCompanion(
        status: Value(status),
        attempts: Value(op.attempts + 1),
        lastAttemptAt: Value(now),
        errorMessage: Value(code),
      ),
    );
    if (op.entity == 'registrar_pago' ||
        op.entity == 'registrar_movimiento_inventario') {
      final criticalState = status == 'completed'
          ? 'confirmed'
          : status == 'pending'
          ? 'pending_sync'
          : rejectionKnown
          ? 'rejected'
          : 'requires_review';
      await db.customStatement(
        'UPDATE critical_operations SET state=?,rejection_known=?,remote_id=?,remote_version=? WHERE operation_id=?',
        [
          criticalState,
          rejectionKnown ? 1 : 0,
          receipt?['transaction_id'] ?? receipt?['movement_id'],
          receipt?['product_version'],
          op.id,
        ],
      );
      await db.customStatement(
        'INSERT INTO critical_events(operation_id,event,at) VALUES(?,?,?)',
        [op.id, criticalState, now],
      );
    }
    if (nextAttempt != null) {
      await db.customStatement(
        'UPDATE sync_operation_state SET next_attempt_at=? WHERE operation_id=?',
        [nextAttempt, op.id],
      );
    }
    if (version != null) {
      // Only rebase successors after our own accepted write, never after a
      // competing remote edit. They keep their original payload for review.
      await db.customStatement(
        "UPDATE sync_operation_state SET base_version=? WHERE operation_id IN (SELECT id FROM sync_queue WHERE entity=? AND entity_id=? AND status='pending')",
        [version, op.entity, op.entityId],
      );
    }
    await trace(op.id, code ?? status, now);
  });

  Stream<(int, int)> watchCounts() => db
      .customSelect(
        "SELECT SUM(CASE WHEN status IN ('pending','processing') THEN 1 ELSE 0 END) AS pending, SUM(CASE WHEN status='failed' AND NOT EXISTS(SELECT 1 FROM critical_operations c WHERE c.operation_id=sync_queue.id AND c.acknowledged=1) THEN 1 ELSE 0 END) AS failed FROM sync_queue",
        readsFrom: {db.syncQueueTable},
      )
      .watch()
      .map(
        (rows) => (
          rows.single.readNullable<int>('pending') ?? 0,
          rows.single.readNullable<int>('failed') ?? 0,
        ),
      );

  Future<void> applyPage(
    String scope,
    PullPage page,
  ) => db.transaction(() async {
    for (final change in page.changes) {
      await _apply(change);
    }
    await db.customStatement(
      'INSERT INTO sync_checkpoint(scope,cursor) VALUES(?,?) ON CONFLICT(scope) DO UPDATE SET cursor=excluded.cursor',
      [scope, page.cursor],
    );
  });

  Future<void> reconcileAccepted() => db.transaction(() async {
    final rows = await db
        .customSelect(
          'SELECT s.* FROM sync_entity_state s JOIN sync_conflicts c ON c.entity=s.entity AND c.entity_id=s.entity_id',
        )
        .get();
    for (final row in rows) {
      await _apply(
        RemoteChange(
          cursor: 0,
          entity: row.read<String>('entity'),
          id: row.read<String>('entity_id'),
          version: row.read<int>('version'),
          deleted: row.read<int>('deleted') != 0,
          data: Map<String, Object?>.from(
            jsonDecode(row.read<String>('server_json')) as Map,
          ),
        ),
        replay: true,
      );
    }
  });

  Future<void> _apply(RemoteChange change, {bool replay = false}) async {
    final previous = await db
        .customSelect(
          'SELECT version FROM sync_entity_state WHERE entity=? AND entity_id=?',
          variables: [Variable(change.entity), Variable(change.id)],
        )
        .getSingleOrNull();
    if (!replay &&
        previous != null &&
        previous.read<int>('version') >= change.version) {
      return;
    }
    final dirty =
        await (db.select(db.syncQueueTable)..where(
              (t) =>
                  t.entity.equals(change.entity) &
                  t.entityId.equals(change.id) &
                  t.status.isIn(['pending', 'processing', 'failed']),
            ))
            .get();
    // RPCs mutate related rows too. Do not overwrite optimistic stock/order
    // while a command is unresolved; persist server image for later review.
    final commands =
        await (db.select(db.syncQueueTable)..where(
              (t) =>
                  t.entity.isIn([
                    'registrar_pago',
                    'registrar_movimiento_inventario',
                  ]) &
                  t.status.isIn(['pending', 'processing', 'failed']),
            ))
            .get();
    final related = commands.where((op) {
      final p = jsonDecode(op.payload) as Map<String, dynamic>;
      return (change.entity == 'productos' &&
              p['p_producto_id'] == change.id) ||
          (change.entity == 'ordenes' && p['p_orden_id'] == change.id) ||
          (change.entity == 'detalle_orden' &&
              (p['p_asignaciones'] as List?)?.any(
                    (a) => (a as Map)['detalle_orden_id'] == change.id,
                  ) ==
                  true);
    }).isNotEmpty;
    final knownRejected = await db
        .customSelect(
          "SELECT q.id FROM critical_operations c JOIN sync_queue q ON q.id=c.operation_id WHERE c.state='rejected'",
        )
        .get();
    final rejectedIds = knownRejected.map((r) => r.read<String>('id')).toSet();
    final activeRelated =
        related &&
        commands.any((op) {
          if (rejectedIds.contains(op.id)) return false;
          final p = jsonDecode(op.payload) as Map;
          return (change.entity == 'productos' &&
                  p['p_producto_id'] == change.id) ||
              (change.entity == 'ordenes' && p['p_orden_id'] == change.id) ||
              (change.entity == 'detalle_orden' &&
                  (p['p_asignaciones'] as List?)?.any(
                        (a) => (a as Map)['detalle_orden_id'] == change.id,
                      ) ==
                      true);
        });
    final decision = conflicts.resolve(
      entity: change.entity,
      dirty: dirty.isNotEmpty || activeRelated,
      baseVersion: dirty.isEmpty
          ? previous?.read<int>('version') ?? 0
          : await baseVersion(dirty.first.id),
      serverVersion: change.version,
    );
    if (decision == ConflictDecision.applyServer) {
      await _writeRow(change);
      await db.customStatement(
        'DELETE FROM sync_conflicts WHERE entity=? AND entity_id=?',
        [change.entity, change.id],
      );
    } else {
      await db.customStatement(
        'INSERT INTO sync_conflicts(entity,entity_id,reason,at) VALUES(?,?,?,?) ON CONFLICT(entity,entity_id) DO UPDATE SET reason=excluded.reason,at=excluded.at',
        [
          change.entity,
          change.id,
          'remote_change_requires_review',
          DateTime.now().millisecondsSinceEpoch,
        ],
      );
    }
    await db.customStatement(
      'INSERT INTO sync_entity_state(entity,entity_id,version,deleted,server_json) VALUES(?,?,?,?,?) ON CONFLICT(entity,entity_id) DO UPDATE SET version=excluded.version,deleted=excluded.deleted,server_json=excluded.server_json',
      [
        change.entity,
        change.id,
        change.version,
        change.deleted ? 1 : 0,
        jsonEncode(change.data),
      ],
    );
  }

  Future<void> _writeRow(RemoteChange change) async {
    final table = db.allTables
        .where((t) => t.actualTableName == change.entity)
        .firstOrNull;
    if (table == null || change.entity == 'sync_queue') {
      throw const SyncContractException();
    }
    final ledger = const {
      'transacciones',
      'pago_detalles',
      'movimientos_inventario',
    }.contains(change.entity);
    if (ledger && change.deleted) throw const SyncContractException();
    if (change.deleted) {
      await db.customStatement(
        'DELETE FROM "${table.actualTableName}" WHERE id=?',
        [change.id],
      );
    } else {
      final values = <String, Object?>{};
      const money = {
        'precio_centavos': 'precio',
        'precio_unitario_centavos': 'precio_unitario',
        'monto_centavos': 'monto',
        'salario_centavos': 'salario',
        'total_efectivo_centavos': 'total_efectivo',
        'total_tarjeta_centavos': 'total_tarjeta',
        'total_otro_centavos': 'total_otro',
        'total_global_centavos': 'total_global',
        'datos_json': 'datos',
      };
      const timestamps = {
        'created_at',
        'updated_at',
        'fecha_registro',
        'fecha_apertura',
        'fecha_cierre',
        'fecha_publicacion',
        'hora_cierre',
      };
      for (final column in table.$columns) {
        final key = money[column.name] ?? column.name;
        if (!change.data.containsKey(key)) continue;
        var value = change.data[key];
        if (value != null &&
            (timestamps.contains(key) ||
                (key == 'fecha' && change.entity == 'transacciones'))) {
          value = DateTime.parse(value as String).millisecondsSinceEpoch;
        } else if (value is bool) {
          value = value ? 1 : 0;
        } else if (key == 'datos') {
          value = jsonEncode(value);
        }
        values[column.name] = value;
      }
      // Preserve legacy provisional rows without deleting or editing a ledger.
      // New commands live exclusively in the outbox until server confirmation.
      if (change.entity == 'transacciones' ||
          change.entity == 'movimientos_inventario') {
        final key = values['idempotency_key'];
        if (key != null) {
          final existing = await db
              .customSelect(
                'SELECT * FROM "${table.actualTableName}" WHERE idempotency_key=?',
                variables: [Variable(key as String)],
              )
              .getSingleOrNull();
          if (existing != null) {
            final fields = change.entity == 'transacciones'
                ? ['orden_id', 'monto_centavos', 'metodo_pago']
                : ['producto_id', 'cantidad', 'tipo', 'referencia_id'];
            if (fields.any((f) => existing.data[f] != values[f])) {
              throw const SyncContractException();
            }
            await db.customStatement(
              'INSERT OR IGNORE INTO sync_ledger_alias(entity,remote_id,local_id) VALUES(?,?,?)',
              [change.entity, change.id, existing.read<String>('id')],
            );
            return;
          }
        }
      }
      if (change.entity == 'pago_detalles') {
        final alias = await db
            .customSelect(
              "SELECT local_id FROM sync_ledger_alias WHERE entity='transacciones' AND remote_id=?",
              variables: [Variable(values['transaccion_id'] as String)],
            )
            .getSingleOrNull();
        if (alias != null) {
          values['transaccion_id'] = alias.read<String>('local_id');
          final matches = await db
              .customSelect(
                'SELECT id FROM pago_detalles WHERE transaccion_id=? AND detalle_orden_id=? AND cantidad=? AND monto_centavos=?',
                variables: [
                  Variable(values['transaccion_id'] as String),
                  Variable(values['detalle_orden_id'] as String),
                  Variable(values['cantidad'] as int),
                  Variable(values['monto_centavos'] as int),
                ],
              )
              .get();
          if (matches.isNotEmpty) return;
        }
      }
      if (values.isEmpty) throw const SyncContractException();
      if (ledger) {
        final existing = await db
            .customSelect(
              'SELECT * FROM "${table.actualTableName}" WHERE id=?',
              variables: [Variable(change.id)],
            )
            .getSingleOrNull();
        if (existing != null &&
            values.entries.any(
              (v) =>
                  v.key != 'created_at' &&
                  v.key != 'fecha' &&
                  existing.data[v.key] != v.value,
            )) {
          throw const SyncContractException();
        }
      }
      if (change.entity == 'venta_diaria') {
        await db.customStatement(
          'DELETE FROM venta_diaria WHERE fecha=? AND id<>?',
          [values['fecha'], values['id']],
        );
      }
      final columns = values.keys.map((k) => '"$k"').join(',');
      final updates = values.keys
          .where((k) => k != 'id')
          .map((k) => '"$k"=excluded."$k"')
          .join(',');
      await db.customStatement(
        'INSERT INTO "${table.actualTableName}" ($columns) VALUES (${List.filled(values.length, '?').join(',')}) ON CONFLICT(id) ${ledger ? 'DO NOTHING' : 'DO UPDATE SET $updates'}',
        values.values.toList(),
      );
    }
    db.notifyUpdates({TableUpdate(table.actualTableName)});
    if (change.entity == 'transacciones') {
      db.notifyUpdates({const TableUpdate('pago_detalles')});
    }
  }
}
