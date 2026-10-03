import 'package:drift/drift.dart';

@TableIndex(name: 'sync_queue_status_created', columns: {#status, #createdAt})

/// Tabla de cola de sincronización offline-first.
///
/// Toda operación realizada sin conexión se registra aquí.
/// [SyncWorker] procesa esta cola cuando detecta conectividad.
///
/// Campos:
/// - [id]: UUID de la operación de sync (no del registro afectado)
/// - [entity]: nombre de la tabla afectada (ej. 'ordenes')
/// - [entityId]: UUID del registro afectado
/// - [operation]: 'INSERT' | 'UPDATE' | 'DELETE'
/// - [payload]: JSON serializado con los datos de la operación
/// - [idempotencyKey]: UUID único para prevenir duplicados en Supabase
/// - [status]: 'pending' | 'processing' | 'completed' | 'failed'
/// - [attempts]: número de intentos de sincronización
/// - [lastAttemptAt]: timestamp del último intento
/// - [errorMessage]: detalle del error si status = 'failed'
class SyncQueueTable extends Table {
  @override
  String get tableName => 'sync_queue';

  TextColumn get id => text()();
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  TextColumn get idempotencyKey => text().unique()();
  IntColumn get createdAt => integer()(); // Unix timestamp en milisegundos
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  IntColumn get lastAttemptAt => integer().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get errorMessage => text().nullable()();

  @override
  List<String> get customConstraints => [
    'CHECK (attempts >= 0)',
    "CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE'))",
    "CHECK (status IN ('pending', 'processing', 'completed', 'failed'))",
  ];

  @override
  Set<Column> get primaryKey => {id};
}

/// Estados posibles de una operación en la sync_queue.
abstract final class SyncStatus {
  static const pending = 'pending';
  static const processing = 'processing';
  static const completed = 'completed';
  static const failed = 'failed';
}

/// Tipos de operación posibles.
abstract final class SyncOperation {
  static const insert = 'INSERT';
  static const update = 'UPDATE';
  static const delete = 'DELETE';
}
