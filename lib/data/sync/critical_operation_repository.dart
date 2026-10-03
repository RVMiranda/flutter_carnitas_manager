import 'package:drift/drift.dart';
import '../local/database/app_database.dart';

enum CriticalOperationState { pendingSync, confirmed, rejected, requiresReview }

class CriticalOperation {
  const CriticalOperation(
    this.id,
    this.kind,
    this.state,
    this.rejectionKnown,
    this.acknowledged,
    this.amountCents,
    this.quantity,
  );
  final String id;
  final String kind;
  final CriticalOperationState state;
  final bool rejectionKnown;
  final bool acknowledged;
  final int? amountCents;
  final int? quantity;
}

/// Local audit and review actions. Never edits a payment or inventory ledger.
class CriticalOperationRepository {
  CriticalOperationRepository(this.db);
  final AppDatabase db;

  Stream<List<CriticalOperation>> watch() => db
      .customSelect(
        "SELECT c.*,q.entity,json_extract(q.payload,'\$.p_monto') AS amount,json_extract(q.payload,'\$.p_cantidad') AS quantity FROM critical_operations c JOIN sync_queue q ON q.id=c.operation_id ORDER BY q.created_at DESC",
        readsFrom: {db.syncQueueTable},
      )
      .watch()
      .map(
        (rows) => rows
            .map(
              (r) => CriticalOperation(
                r.read<String>('operation_id'),
                r.read<String>('entity'),
                switch (r.read<String>('state')) {
                  'confirmed' => CriticalOperationState.confirmed,
                  'rejected' => CriticalOperationState.rejected,
                  'requires_review' => CriticalOperationState.requiresReview,
                  _ => CriticalOperationState.pendingSync,
                },
                r.read<int>('rejection_known') != 0,
                r.read<int>('acknowledged') != 0,
                r.readNullable<int>('amount'),
                r.readNullable<int>('quantity'),
              ),
            )
            .toList(),
      );

  Future<void> acknowledgeRejection(String id) => db.transaction(() async {
    final count = await db.customUpdate(
      "UPDATE critical_operations SET state='rejected',acknowledged=1 WHERE operation_id=? AND rejection_known=1 AND acknowledged=0",
      variables: [Variable(id)],
      updates: {db.syncQueueTable},
    );
    if (count != 1) {
      throw StateError('La operación necesita confirmación del servidor.');
    }
    await _event(id, 'rejection_acknowledged_reservation_released');
  });

  /// Unknown outcomes may only replay the original immutable command/key.
  Future<void> retryUnknown(String id) => db.transaction(() async {
    final count = await db.customUpdate(
      "UPDATE critical_operations SET state='pending_sync' WHERE operation_id=? AND state='requires_review' AND rejection_known=0",
      variables: [Variable(id)],
      updates: {db.syncQueueTable},
    );
    if (count != 1) throw StateError('Esta operación no admite reintento.');
    await db.customStatement(
      "UPDATE sync_queue SET status='pending',attempts=0,error_message=NULL WHERE id=?",
      [id],
    );
    await db.customStatement(
      'UPDATE sync_operation_state SET next_attempt_at=0 WHERE operation_id=?',
      [id],
    );
    await _event(id, 'same_key_replay_requested');
  });

  Future<int> reservedDelta(String productId) async {
    final row = await db
        .customSelect(
          "SELECT COALESCE(SUM(MIN(CAST(json_extract(q.payload,'\$.p_cantidad') AS INTEGER),0)),0) AS delta FROM sync_queue q JOIN critical_operations c ON c.operation_id=q.id WHERE c.legacy_optimistic=0 AND q.entity='registrar_movimiento_inventario' AND json_extract(q.payload,'\$.p_producto_id')=? AND (c.state IN ('pending_sync','requires_review') OR (c.state='confirmed' AND (NOT EXISTS(SELECT 1 FROM movimientos_inventario m WHERE m.idempotency_key=q.idempotency_key) OR COALESCE((SELECT version FROM sync_entity_state WHERE entity='productos' AND entity_id=json_extract(q.payload,'\$.p_producto_id')),0)<COALESCE(c.remote_version,9223372036854775807))))",
          variables: [Variable(productId)],
        )
        .getSingle();
    // Incoming stock is not available before confirmation.
    return row.read<int>('delta');
  }

  Future<void> _event(String id, String event) => db.customStatement(
    'INSERT INTO critical_events(operation_id,event,at) VALUES(?,?,?)',
    [id, event, DateTime.now().millisecondsSinceEpoch],
  );
}
