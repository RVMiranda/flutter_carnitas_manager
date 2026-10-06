import 'dart:async';
import 'package:exquisssita_manager/data/local/database/app_database.dart';
import 'package:exquisssita_manager/data/repositories/sync_repository.dart';
import 'package:exquisssita_manager/data/sync/sync_models.dart';

class FakeSyncRepository implements SyncRepository {
  @override
  String? scope = 'user-a';
  final notifications = StreamController<void>.broadcast();
  @override
  Stream<void> get signals => notifications.stream;
  final List<RemoteChange> changes = [];
  final Map<String, Map<String, Object?>> receipts = {};
  Object? reject;
  Map<String, Object?>? nextResult;
  bool loseResponse = false;
  int calls = 0;
  final List<int?> watermarks = [];
  @override
  Future<Map<String, Object?>> push(
    SyncQueueTableData operation,
    int baseVersion,
  ) async {
    calls++;
    final error = reject;
    if (error != null) throw error;
    final result = receipts.putIfAbsent(
      operation.idempotencyKey,
      () =>
          nextResult ??
          {
            'version': baseVersion + 1,
            'status': 'confirmed',
            if (operation.entity == 'registrar_pago')
              'transaction_id': 'remote-${operation.entityId}',
            if (operation.entity == 'registrar_movimiento_inventario')
              'movement_id': 'remote-${operation.entityId}',
          },
    );
    if (loseResponse) {
      loseResponse = false;
      throw TimeoutException('secret response');
    }
    return result;
  }

  @override
  Future<PullPage> pull({required int cursor, int? watermark}) async {
    watermarks.add(watermark);
    final upper = watermark ?? (changes.isEmpty ? cursor : changes.last.cursor);
    final page = changes
        .where((c) => c.cursor > cursor && c.cursor <= upper)
        .take(2)
        .toList();
    final next = page.isEmpty ? upper : page.last.cursor;
    return PullPage(page, next, upper, next < upper);
  }

  @override
  Future<void> dispose() => notifications.close();
}
