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
/// Versión actual del schema: 4.
/// Las migraciones son incrementales y conservan las bases existentes.
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
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(syncQueueTable);
        await m.createTable(mesasTable);
        await m.createTable(clientesTable);
        await m.createTable(productosTable);
        await m.createTable(ordenesTable);
        await m.createTable(detalleOrdenTable);
        await m.createTable(transaccionesTable);
        await m.createTable(pagoDetallesTable);
        await m.createTable(movimientosInventarioTable);
        await m.createTable(visitasClientesTable);
        await m.createTable(auditoriaEventosTable);
      }
      if (from < 3) {
        await m.createTable(empleadosTable);
        await m.createTable(promocionesTable);
        await m.createTable(ventaDiariaTable);
        await m.createTable(historialPagosEmpleadosTable);
      }
      if (from < 4) {
        final clientesColumns = await customSelect(
          'PRAGMA table_info(clientes)',
        ).get();
        if (!clientesColumns.any((row) => row.data['name'] == 'qr_token_hash')) {
          await m.addColumn(clientesTable, clientesTable.qrTokenHash);
        }
        final visitasColumns = await customSelect(
          'PRAGMA table_info(visitas_clientes)',
        ).get();
        if (!visitasColumns.any((row) => row.data['name'] == 'usuario_id')) {
          await m.addColumn(visitasClientesTable, visitasClientesTable.usuarioId);
        }
      }
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_sync_queue_status_created '
        'ON sync_queue (status, created_at)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_ordenes_estado_apertura '
        'ON ordenes (estado, fecha_apertura)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_detalle_orden_orden '
        'ON detalle_orden (orden_id)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_transacciones_fecha '
        'ON transacciones (fecha)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_visitas_usuario_fecha '
        'ON visitas_clientes (usuario_id, fecha)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_venta_diaria_fecha '
        'ON venta_diaria (fecha)',
      );
    },
  );

  static QueryExecutor _openConnection(String name) {
    return driftDatabase(name: name);
  }
}
