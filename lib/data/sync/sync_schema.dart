import '../local/database/app_database.dart';

/// Internal Drift-managed metadata; intentionally separate from domain tables.
Future<void> createSyncSchema(AppDatabase db) async {
  for (final sql in [
    'CREATE TABLE IF NOT EXISTS sync_identity (id INTEGER PRIMARY KEY CHECK(id=1), owner TEXT NOT NULL)',
    'CREATE TABLE IF NOT EXISTS sync_checkpoint (scope TEXT PRIMARY KEY, cursor INTEGER NOT NULL DEFAULT 0)',
    'CREATE TABLE IF NOT EXISTS sync_entity_state (entity TEXT NOT NULL, entity_id TEXT NOT NULL, version INTEGER NOT NULL, deleted INTEGER NOT NULL DEFAULT 0, server_json TEXT NOT NULL, PRIMARY KEY(entity, entity_id))',
    'CREATE TABLE IF NOT EXISTS sync_operation_state (operation_id TEXT PRIMARY KEY, base_version INTEGER NOT NULL DEFAULT 0, next_attempt_at INTEGER NOT NULL DEFAULT 0)',
    'CREATE TABLE IF NOT EXISTS sync_trace (id INTEGER PRIMARY KEY AUTOINCREMENT, operation_id TEXT, event TEXT NOT NULL, at INTEGER NOT NULL)',
    'CREATE TABLE IF NOT EXISTS sync_conflicts (entity TEXT NOT NULL, entity_id TEXT NOT NULL, reason TEXT NOT NULL, at INTEGER NOT NULL, PRIMARY KEY(entity, entity_id))',
    'CREATE INDEX IF NOT EXISTS sync_entity_queue_order ON sync_queue(entity,entity_id,created_at)',
    "CREATE TRIGGER IF NOT EXISTS sync_capture_base AFTER INSERT ON sync_queue BEGIN INSERT OR IGNORE INTO sync_operation_state(operation_id,base_version) VALUES(NEW.id, COALESCE((SELECT version FROM sync_entity_state WHERE entity=NEW.entity AND entity_id=NEW.entity_id),0)); END",
    'INSERT OR IGNORE INTO sync_operation_state(operation_id) SELECT id FROM sync_queue',
    "CREATE TABLE IF NOT EXISTS critical_operations (operation_id TEXT PRIMARY KEY, state TEXT NOT NULL CHECK(state IN ('pending_sync','confirmed','rejected','requires_review')), rejection_known INTEGER NOT NULL DEFAULT 0, acknowledged INTEGER NOT NULL DEFAULT 0, remote_id TEXT, remote_version INTEGER, legacy_optimistic INTEGER NOT NULL DEFAULT 0)",
    "CREATE TABLE IF NOT EXISTS critical_events (id INTEGER PRIMARY KEY AUTOINCREMENT, operation_id TEXT NOT NULL, event TEXT NOT NULL, at INTEGER NOT NULL)",
    "CREATE TRIGGER IF NOT EXISTS critical_capture AFTER INSERT ON sync_queue WHEN NEW.entity IN ('registrar_pago','registrar_movimiento_inventario') BEGIN INSERT INTO critical_operations(operation_id,state) VALUES(NEW.id,'pending_sync'); INSERT INTO critical_events(operation_id,event,at) VALUES(NEW.id,'intent_recorded',NEW.created_at); END",
    "INSERT OR IGNORE INTO critical_operations(operation_id,state,legacy_optimistic) SELECT id, CASE status WHEN 'completed' THEN 'confirmed' WHEN 'failed' THEN 'requires_review' ELSE 'pending_sync' END,1 FROM sync_queue WHERE entity IN ('registrar_pago','registrar_movimiento_inventario')",
    'CREATE TABLE IF NOT EXISTS sync_ledger_alias (entity TEXT NOT NULL, remote_id TEXT NOT NULL, local_id TEXT NOT NULL, PRIMARY KEY(entity,remote_id))',
  ]) {
    await db.customStatement(sql);
  }
  for (final table in [
    'transacciones',
    'pago_detalles',
    'movimientos_inventario',
    'critical_events',
  ]) {
    for (final action in ['UPDATE', 'DELETE']) {
      await db.customStatement(
        "CREATE TRIGGER IF NOT EXISTS ${table}_immutable_${action.toLowerCase()} BEFORE $action ON $table BEGIN SELECT RAISE(ABORT,'append_only'); END",
      );
    }
  }
  await db.customStatement(
    "CREATE TRIGGER IF NOT EXISTS critical_intent_immutable BEFORE UPDATE OF payload,idempotency_key,entity,entity_id ON sync_queue WHEN OLD.entity IN ('registrar_pago','registrar_movimiento_inventario') BEGIN SELECT RAISE(ABORT,'immutable_intent'); END",
  );
  await db.customStatement(
    "CREATE TRIGGER IF NOT EXISTS critical_intent_retained BEFORE DELETE ON sync_queue WHEN OLD.entity IN ('registrar_pago','registrar_movimiento_inventario') BEGIN SELECT RAISE(ABORT,'immutable_intent'); END",
  );
}
