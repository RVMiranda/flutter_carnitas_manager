import 'dart:convert';

import 'package:drift/drift.dart';

import 'app_database.dart';
import '../tables/sync_queue_table.dart';

/// Operaciones transaccionales de persistencia local.
///
/// Esta capa evita que ViewModels conozcan Drift y centraliza las invariantes
/// que deben cumplirse antes de encolar una operación de sincronización.
class LocalPersistence {
  LocalPersistence(this._db);

  final AppDatabase _db;

  Stream<List<MesasTableData>> watchMesas() => (_db.select(
    _db.mesasTable,
  )..orderBy([(t) => OrderingTerm(expression: t.numeroMesa)])).watch();

  Stream<List<ProductosTableData>> watchProductos({bool soloActivos = true}) {
    final query = _db.select(_db.productosTable)
      ..orderBy([(t) => OrderingTerm(expression: t.nombre)]);
    if (soloActivos) query.where((t) => t.activo.equals(true));
    return query.watch();
  }

  Stream<List<OrdenesTableData>> watchOrdenesAbiertas() =>
      (_db.select(_db.ordenesTable)
            ..where((t) => t.estado.equals('Abierta'))
            ..orderBy([(t) => OrderingTerm.desc(t.fechaApertura)]))
          .watch();

  Stream<List<DetalleOrdenTableData>> watchDetalles(String ordenId) =>
      (_db.select(_db.detalleOrdenTable)
            ..where((t) => t.ordenId.equals(ordenId))
            ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
          .watch();

  Future<void> saveOrderWithDetails({
    required OrdenesTableCompanion order,
    required List<DetalleOrdenTableCompanion> details,
    required SyncQueueTableCompanion queueEntry,
  }) async {
    await _db.transaction(() async {
      await _db.into(_db.ordenesTable).insertOnConflictUpdate(order);
      await _db.batch((batch) {
        batch.insertAllOnConflictUpdate(_db.detalleOrdenTable, details);
        batch.insert(_db.syncQueueTable, queueEntry);
      });
    });
  }

  Future<List<SyncQueueTableData>> pendingSyncBatch({
    int limit = 50,
    int? now,
  }) async {
    final rows =
        await (_db.select(_db.syncQueueTable)
              ..where((t) => t.status.equals(SyncStatus.pending))
              ..orderBy([(t) => OrderingTerm(expression: t.createdAt)])
              ..limit(limit))
            .get();
    if (now == null) return rows;
    return rows.where((row) {
      if (row.lastAttemptAt == null) return true;
      final delay = _retryDelayMs(row.attempts);
      return row.lastAttemptAt! + delay <= now;
    }).toList();
  }

  static int _retryDelayMs(int attempts) {
    final exponent = attempts.clamp(0, 6);
    return 1000 * (1 << exponent);
  }

  Future<void> markSyncProcessing(String id, int now) =>
      (_db.update(_db.syncQueueTable)..where((t) => t.id.equals(id))).write(
        SyncQueueTableCompanion(
          status: const Value(SyncStatus.processing),
          lastAttemptAt: Value(now),
        ),
      );

  Future<void> markSyncCompleted(String id) =>
      (_db.update(_db.syncQueueTable)..where((t) => t.id.equals(id))).write(
        const SyncQueueTableCompanion(status: Value(SyncStatus.completed)),
      );

  Future<void> markSyncFailed(String id, String error, int now) async {
    await (_db.update(_db.syncQueueTable)..where((t) => t.id.equals(id))).write(
      SyncQueueTableCompanion(
        status: const Value(SyncStatus.failed),
        errorMessage: Value(error),
        lastAttemptAt: Value(now),
      ),
    );
  }

  Future<void> markSyncRetry({
    required String id,
    required int attempts,
    required int now,
    required String error,
  }) => (_db.update(_db.syncQueueTable)..where((t) => t.id.equals(id))).write(
    SyncQueueTableCompanion(
      status: const Value(SyncStatus.pending),
      attempts: Value(attempts + 1),
      lastAttemptAt: Value(now),
      errorMessage: Value(error),
    ),
  );

  /// Convierte un mapa de datos en payload determinista para la cola.
  static String encodePayload(Map<String, Object?> payload) =>
      jsonEncode(payload);
}
