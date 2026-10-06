import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../data/local/database/app_database.dart';
import '../../../data/local/database/local_persistence.dart';
import '../domain/order_models.dart';
import '../../../data/sync/operational_sync_payload.dart';

class LocalOrdersRepository implements OrdersRepository {
  LocalOrdersRepository(this.db);
  final AppDatabase db;
  final _uuid = const Uuid();

  @override
  Future<int> retryLegacyOperations(String orderId) => db.transaction(() async {
    final details = await (db.select(
      db.detalleOrdenTable,
    )..where((t) => t.ordenId.equals(orderId))).get();
    final operations = await (db.select(
      db.syncQueueTable,
    )..where((t) => t.status.equals('failed'))).get();
    var count = 0;
    for (final operation in operations) {
      final belongs =
          (operation.entity == 'ordenes' && operation.entityId == orderId) ||
          (operation.entity == 'detalle_orden' &&
              details.any((d) => d.id == operation.entityId));
      if (!belongs || operation.errorMessage != 'operation_requires_review') {
        continue;
      }
      final payload = Map<String, dynamic>.from(
        jsonDecode(operation.payload) as Map,
      );
      if (!hasLegacyOperationalPayload(operation.entity, payload)) continue;
      await (db.update(
        db.syncQueueTable,
      )..where((t) => t.id.equals(operation.id))).write(
        const SyncQueueTableCompanion(
          status: Value('pending'),
          errorMessage: Value(null),
        ),
      );
      await db.customStatement(
        'UPDATE sync_operation_state SET next_attempt_at=0 WHERE operation_id=?',
        [operation.id],
      );
      await db.customStatement(
        'INSERT INTO sync_trace(operation_id,event,at) VALUES(?,?,?)',
        [
          operation.id,
          'operator_requested_legacy_retry',
          DateTime.now().millisecondsSinceEpoch,
        ],
      );
      count++;
    }
    if (count > 0) {
      final order = await (db.select(
        db.ordenesTable,
      )..where((t) => t.id.equals(orderId))).getSingleOrNull();
      final tableId = order?.mesaId;
      if (tableId != null) {
        final active =
            await (db.select(db.ordenesTable)..where(
                  (t) => t.mesaId.equals(tableId) & t.estado.equals('Abierta'),
                ))
                .getSingleOrNull();
        await _enqueue('UPDATE', 'mesas', tableId, {
          'id': tableId,
          'estado': active == null ? 'Libre' : 'Ocupada',
        });
      }
    }
    return count;
  });

  @override
  Stream<List<TableSummary>> watchTables() => db
      .customSelect(
        '''
    SELECT m.*, EXISTS(SELECT 1 FROM sync_queue q WHERE q.status IN ('pending','processing')
      AND ((q.entity='mesas' AND q.entity_id=m.id) OR (q.entity='ordenes' AND q.entity_id IN (SELECT id FROM ordenes WHERE mesa_id=m.id)))) AS pending,
      EXISTS(SELECT 1 FROM sync_queue q WHERE q.status='failed'
      AND ((q.entity='mesas' AND q.entity_id=m.id) OR (q.entity='ordenes' AND q.entity_id IN (SELECT id FROM ordenes WHERE mesa_id=m.id)))) AS failed,
      EXISTS(SELECT 1 FROM ordenes o WHERE o.mesa_id=m.id AND o.estado='Abierta') AS occupied
    FROM mesas m
  ''',
        readsFrom: {db.mesasTable, db.ordenesTable, db.syncQueueTable},
      )
      .watch()
      .map((rows) {
        final tables = rows
            .map(
              (r) => TableSummary(
                id: r.read<String>('id'),
                number: r.read<String>('numero_mesa'),
                status: r.read<int>('occupied') == 1
                    ? 'Ocupada'
                    : r.read<String>('estado'),
                pendingSync: r.read<int>('pending') == 1,
                syncFailed: r.read<int>('failed') == 1,
              ),
            )
            .toList();
        tables.sort((a, b) {
          final x = int.tryParse(a.number), y = int.tryParse(b.number);
          return x != null && y != null
              ? x.compareTo(y)
              : a.number.compareTo(b.number);
        });
        return tables;
      });

  @override
  Future<void> createTable(String number) async {
    final parsed = int.tryParse(number.trim());
    if (parsed == null || parsed <= 0 || parsed > 9999) {
      throw ArgumentError('Número de mesa inválido.');
    }
    final normalized = parsed.toString();
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = _uuid.v4();
    await db.transaction(() async {
      final tables = await db.select(db.mesasTable).get();
      if (tables.any((t) => int.tryParse(t.numeroMesa) == parsed)) {
        throw StateError('Ya existe una mesa con ese número.');
      }
      await db
          .into(db.mesasTable)
          .insert(
            MesasTableCompanion.insert(
              id: id,
              numeroMesa: normalized,
              createdAt: now,
              updatedAt: now,
              isSynced: const Value(false),
            ),
          );
      await _enqueue('INSERT', 'mesas', id, {
        'id': id,
        'numero_mesa': normalized,
        'estado': 'Libre',
      });
    });
  }

  @override
  Future<OrderSummary> openOrResumeOrder({
    String? tableId,
    required ServiceType serviceType,
  }) => db.transaction(() async {
    if (tableId != null) {
      final existing =
          await (db.select(db.ordenesTable)..where(
                (t) => t.mesaId.equals(tableId) & t.estado.equals('Abierta'),
              ))
              .getSingleOrNull();
      if (existing != null) return _mapOrder(existing);
    }
    return openOrder(tableId: tableId, serviceType: serviceType);
  });

  @override
  Stream<List<OrderSummary>> watchOpenOrders() =>
      (db.select(db.ordenesTable)
            ..where((t) => t.estado.equals('Abierta'))
            ..orderBy([(t) => OrderingTerm.desc(t.fechaApertura)]))
          .watch()
          .asyncMap((rows) async => Future.wait(rows.map(_mapOrder)));

  @override
  Stream<OrderSummary?> watchOrder(String orderId) => db
      .customSelect(
        'SELECT id FROM ordenes WHERE id=?',
        variables: [Variable(orderId)],
        readsFrom: {
          db.ordenesTable,
          db.detalleOrdenTable,
          db.productosTable,
          db.mesasTable,
          db.syncQueueTable,
        },
      )
      .watch()
      .asyncMap((rows) async {
        if (rows.isEmpty) return null;
        final row = await (db.select(
          db.ordenesTable,
        )..where((t) => t.id.equals(orderId))).getSingle();
        return _mapOrder(row);
      });

  @override
  Future<OrderSummary> openOrder({
    String? tableId,
    required ServiceType serviceType,
    String? notes,
  }) async {
    if (serviceType == ServiceType.table && tableId == null) {
      throw ArgumentError('tableId es requerido para una orden de mesa');
    }
    final id = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    final type = serviceType == ServiceType.table ? 'Mesa' : 'Para llevar';
    await db.transaction(() async {
      if (tableId != null) {
        final table = await (db.select(
          db.mesasTable,
        )..where((t) => t.id.equals(tableId))).getSingleOrNull();
        if (table == null) throw StateError('Mesa no encontrada.');
        final existing =
            await (db.select(db.ordenesTable)..where(
                  (t) => t.mesaId.equals(tableId) & t.estado.equals('Abierta'),
                ))
                .getSingleOrNull();
        if (existing != null) {
          throw StateError('La mesa ya tiene una orden abierta');
        }
        if (table.estado != 'Libre') {
          throw StateError(
            'La mesa no está libre y su orden no está disponible. Sincroniza antes de abrir otra.',
          );
        }
        await (db.update(db.mesasTable)..where((t) => t.id.equals(tableId)))
            .write(const MesasTableCompanion(estado: Value('Ocupada')));
      }
      await db
          .into(db.ordenesTable)
          .insert(
            OrdenesTableCompanion.insert(
              id: id,
              mesaId: Value(tableId),
              tipoServicio: type,
              notas: Value(notes),
              fechaApertura: now,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _enqueue('INSERT', 'ordenes', id, {
        'id': id,
        'mesa_id': tableId,
        'tipo_servicio': type,
        'estado': 'Abierta',
        'fecha_apertura': DateTime.fromMillisecondsSinceEpoch(
          now,
        ).toUtc().toIso8601String(),
        'notas': notes,
      });
      if (tableId != null) {
        await _enqueue('UPDATE', 'mesas', tableId, {
          'id': tableId,
          'estado': 'Ocupada',
        });
      }
    });
    return OrderSummary(
      id: id,
      serviceType: serviceType,
      status: OrderStatus.open,
      tableId: tableId,
      notes: notes,
    );
  }

  @override
  Future<void> addProduct({
    required String orderId,
    required String productId,
    required int quantity,
    String? notes,
  }) async {
    if (quantity <= 0) {
      throw ArgumentError('La cantidad debe ser mayor que cero');
    }
    final product =
        await (db.select(db.productosTable)
              ..where((t) => t.id.equals(productId) & t.activo.equals(true)))
            .getSingleOrNull();
    if (product == null) throw StateError('Producto no disponible');
    final order =
        await (db.select(db.ordenesTable)
              ..where((t) => t.id.equals(orderId) & t.estado.equals('Abierta')))
            .getSingleOrNull();
    if (order == null) throw StateError('La orden no está abierta');
    final detailId = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      await db
          .into(db.detalleOrdenTable)
          .insert(
            DetalleOrdenTableCompanion.insert(
              id: detailId,
              ordenId: orderId,
              productoId: productId,
              cantidad: quantity,
              precioUnitarioCentavos: product.precioCentavos,
              notas: Value(notes),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _enqueue('INSERT', 'detalle_orden', detailId, {
        'id': detailId,
        'orden_id': orderId,
        'producto_id': productId,
        'cantidad': quantity,
        'precio_unitario': product.precioCentavos,
        'notas': notes,
      });
    });
  }

  @override
  Future<void> updateQuantity({
    required String detailId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      throw ArgumentError('La cantidad debe ser mayor que cero');
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final changed =
        await (db.update(
          db.detalleOrdenTable,
        )..where((t) => t.id.equals(detailId))).write(
          DetalleOrdenTableCompanion(
            cantidad: Value(quantity),
            updatedAt: Value(now),
          ),
        );
    if (changed == 0) throw StateError('Detalle no encontrado');
    await _enqueue('UPDATE', 'detalle_orden', detailId, {
      'id': detailId,
      'cantidad': quantity,
    });
  }

  @override
  Future<void> updateNotes({
    required String orderId,
    required String? notes,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final changed =
        await (db.update(db.ordenesTable)
              ..where((t) => t.id.equals(orderId) & t.estado.equals('Abierta')))
            .write(
              OrdenesTableCompanion(notas: Value(notes), updatedAt: Value(now)),
            );
    if (changed == 0) throw StateError('La orden no está abierta');
    await _enqueue('UPDATE', 'ordenes', orderId, {
      'id': orderId,
      'notas': notes,
    });
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      final order =
          await (db.select(db.ordenesTable)..where(
                (t) => t.id.equals(orderId) & t.estado.equals('Abierta'),
              ))
              .getSingleOrNull();
      if (order == null) throw StateError('La orden no está abierta');
      await (db.update(
        db.ordenesTable,
      )..where((t) => t.id.equals(orderId))).write(
        OrdenesTableCompanion(
          estado: const Value('Cancelada'),
          fechaCierre: Value(now),
          updatedAt: Value(now),
        ),
      );
      if (order.mesaId != null) {
        await (db.update(db.mesasTable)
              ..where((t) => t.id.equals(order.mesaId!)))
            .write(const MesasTableCompanion(estado: Value('Libre')));
      }
      await _enqueue('UPDATE', 'ordenes', orderId, {
        'id': orderId,
        'estado': 'Cancelada',
        'fecha_cierre': DateTime.fromMillisecondsSinceEpoch(
          now,
        ).toUtc().toIso8601String(),
      });
      if (order.mesaId != null) {
        await _enqueue('UPDATE', 'mesas', order.mesaId!, {
          'id': order.mesaId,
          'estado': 'Libre',
        });
      }
    });
  }

  Future<void> _enqueue(
    String operation,
    String entity,
    String entityId,
    Map<String, Object?> payload,
  ) async {
    final latest =
        (await db
                .customSelect(
                  'SELECT COALESCE(MAX(created_at),0) AS latest FROM sync_queue',
                )
                .getSingle())
            .read<int>('latest');
    final now = DateTime.now().millisecondsSinceEpoch;
    await db
        .into(db.syncQueueTable)
        .insert(
          SyncQueueTableCompanion.insert(
            id: _uuid.v4(),
            entity: entity,
            entityId: entityId,
            operation: operation,
            payload: LocalPersistence.encodePayload(payload),
            idempotencyKey: _uuid.v4(),
            createdAt: now > latest ? now : latest + 1,
          ),
        );
  }

  Future<OrderSummary> _mapOrder(OrdenesTableData row) async {
    final table = row.mesaId == null
        ? null
        : await (db.select(
            db.mesasTable,
          )..where((t) => t.id.equals(row.mesaId!))).getSingleOrNull();
    final details = await (db.select(
      db.detalleOrdenTable,
    )..where((t) => t.ordenId.equals(row.id))).get();
    final products = await (db.select(
      db.productosTable,
    )..where((t) => t.id.isIn(details.map((d) => d.productoId)))).get();
    final byId = {for (final p in products) p.id: p};
    final detailIds = details.map((d) => d.id).toSet();
    final operations =
        await (db.select(db.syncQueueTable)..where(
              (q) =>
                  (q.entity.equals('ordenes') & q.entityId.equals(row.id)) |
                  (q.entity.equals('detalle_orden') &
                      q.entityId.isIn(detailIds)),
            ))
            .get();
    final lines = details
        .map(
          (d) => OrderLine(
            id: d.id,
            productId: d.productoId,
            name: byId[d.productoId]?.nombre ?? 'Producto',
            quantity: d.cantidad,
            unitPriceCents: d.precioUnitarioCentavos,
            notes: d.notas,
          ),
        )
        .toList(growable: false);
    return OrderSummary(
      id: row.id,
      serviceType: row.tipoServicio == 'Mesa'
          ? ServiceType.table
          : ServiceType.takeaway,
      status: row.estado == 'Abierta'
          ? OrderStatus.open
          : row.estado == 'Cancelada'
          ? OrderStatus.cancelled
          : OrderStatus.closed,
      tableId: row.mesaId,
      tableNumber: table?.numeroMesa,
      notes: row.notas,
      lines: lines,
      pendingSync: operations.any(
        (q) => q.status == 'pending' || q.status == 'processing',
      ),
      syncFailed: operations.any((q) => q.status == 'failed'),
    );
  }
}
