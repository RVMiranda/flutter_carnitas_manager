import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:exquisssita_manager/data/local/database/app_database.dart';
import 'package:exquisssita_manager/data/local/database/local_persistence.dart';
import 'package:exquisssita_manager/data/local/tables/sync_queue_table.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase database;
  late LocalPersistence persistence;

  setUp(() {
    database = AppDatabase(executor: NativeDatabase.memory());
    persistence = LocalPersistence(database);
  });

  tearDown(() async => database.close());

  test(
    'persiste productos y conserva nombres compatibles con Supabase',
    () async {
      await database
          .into(database.productosTable)
          .insert(
            ProductosTableCompanion.insert(
              id: 'product-1',
              nombre: 'Agua',
              precioCentavos: 2000,
              categoria: 'Bebidas',
              createdAt: 1,
              updatedAt: 1,
            ),
          );

      final product = await (database.select(
        database.productosTable,
      )..where((table) => table.id.equals('product-1'))).getSingle();

      expect(product.nombre, 'Agua');
      expect(product.precioCentavos, 2000);
    },
  );

  test('la cola de sincronización mantiene operaciones pendientes', () async {
    await database
        .into(database.syncQueueTable)
        .insert(
          SyncQueueTableCompanion.insert(
            id: 'operation-1',
            entity: 'productos',
            entityId: 'product-1',
            operation: SyncOperation.insert,
            payload: LocalPersistence.encodePayload({'id': 'product-1'}),
            idempotencyKey: 'idem-1',
            createdAt: 1,
          ),
        );

    final pending = await persistence.pendingSyncBatch();

    expect(pending, hasLength(1));
    expect(pending.single.status, SyncStatus.pending);
  });
}
