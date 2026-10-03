import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../tables/sync_queue_table.dart';
import '../tables/mesas_table.dart';
import '../tables/business_tables.dart';

part 'app_database.g.dart';

/// Base de datos local principal usando Drift (SQLite).
///
/// Es la fuente de verdad local. La UI siempre lee desde aquí.
/// Supabase se sincroniza en background mediante [SyncWorker].
///
/// Versión actual del schema: 1
/// Las migraciones se manejan en [_migration].
@DriftDatabase(
  tables: [
    SyncQueueTable,
    MesasTable,
    ClientesTable,
    ProductosTable,
    OrdenesTable,
    DetalleOrdenTable,
    TransaccionesTable,
    PagoDetallesTable,
    MovimientosInventarioTable,
    VisitasClientesTable,
    AuditoriaEventosTable,
    EmpleadosTable,
    PromocionesTable,
    VentaDiariaTable,
    HistorialPagosEmpleadosTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({String name = 'exquisssita_manager', QueryExecutor? executor})
    : super(executor ?? _openConnection(name));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createAll();
      }
      if (from < 3) {
        await m.createTable(empleadosTable);
        await m.createTable(promocionesTable);
        await m.createTable(ventaDiariaTable);
        await m.createTable(historialPagosEmpleadosTable);
      }
    },
  );

  static QueryExecutor _openConnection(String name) {
    return driftDatabase(name: name);
  }
}
