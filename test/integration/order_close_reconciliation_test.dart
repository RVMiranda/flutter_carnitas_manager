import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exquisssita_manager/data/local/database/app_database.dart';
import 'package:exquisssita_manager/data/sync/drift_sync_store.dart';
import 'package:exquisssita_manager/data/sync/pull_processor.dart';
import 'package:exquisssita_manager/data/sync/sync_models.dart';
import 'package:exquisssita_manager/features/orders/data/local_orders_repository.dart';
import 'package:exquisssita_manager/features/orders/domain/order_models.dart';
import '../sync/fake_sync_repository.dart';

void main() {
  test(
    'cierre autoritativo remoto se refleja en Drift y en la consulta de órdenes',
    () async {
      final db = AppDatabase(executor: NativeDatabase.memory());
      final remote = FakeSyncRepository()..scope = 'cashier';
      try {
        remote.changes.add(
          const RemoteChange(
            cursor: 1,
            entity: 'ordenes',
            id: 'order',
            version: 1,
            data: {
              'id': 'order',
              'tipo_servicio': 'Para llevar',
              'estado': 'Abierta',
              'fecha_apertura': '2026-10-03T12:00:00Z',
              'created_at': '2026-10-03T12:00:00Z',
              'updated_at': '2026-10-03T12:00:00Z',
            },
          ),
        );
        final pull = PullProcessor(DriftSyncStore(db), remote);
        await pull.run(scope: 'cashier', canRun: () => true);
        final orders = LocalOrdersRepository(db);
        expect(
          (await orders.watchOrder('order').first)!.status,
          OrderStatus.open,
        );
        remote.changes.add(
          const RemoteChange(
            cursor: 2,
            entity: 'ordenes',
            id: 'order',
            version: 2,
            data: {
              'id': 'order',
              'tipo_servicio': 'Para llevar',
              'estado': 'Cerrada',
              'fecha_apertura': '2026-10-03T12:00:00Z',
              'fecha_cierre': '2026-10-03T12:30:00Z',
              'created_at': '2026-10-03T12:00:00Z',
              'updated_at': '2026-10-03T12:30:00Z',
            },
          ),
        );
        await pull.run(scope: 'cashier', canRun: () => true);
        expect(
          (await orders.watchOrder('order').first)!.status,
          OrderStatus.closed,
        );
        expect(await orders.watchOpenOrders().first, isEmpty);
        expect(await DriftSyncStore(db).cursor('cashier'), 2);
      } finally {
        await remote.dispose();
        await db.close();
      }
    },
  );
}
