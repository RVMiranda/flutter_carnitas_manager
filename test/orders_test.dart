import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:exquisssita_manager/data/local/database/app_database.dart';
import 'package:exquisssita_manager/features/orders/data/local_orders_repository.dart';
import 'package:exquisssita_manager/features/orders/domain/order_models.dart';

void main() {
  late AppDatabase db;
  late LocalOrdersRepository repository;

  setUp(() {
    db = AppDatabase(executor: NativeDatabase.memory());
    repository = LocalOrdersRepository(db);
  });
  tearDown(() => db.close());

  test('crea orden, agrega producto y conserva el detalle en Drift', () async {
    await db.into(db.mesasTable).insert(
      MesasTableCompanion.insert(
        id: 'table-1', numeroMesa: '1', createdAt: 1, updatedAt: 1,
      ),
    );
    await db.into(db.productosTable).insert(
      ProductosTableCompanion.insert(
        id: 'product-1', nombre: 'Taco', precioCentavos: 2500,
        categoria: 'Tacos', createdAt: 1, updatedAt: 1,
      ),
    );

    final order = await repository.openOrder(
      tableId: 'table-1', serviceType: ServiceType.table,
    );
    await repository.addProduct(
      orderId: order.id, productId: 'product-1', quantity: 2,
    );
    final stored = await repository.watchOrder(order.id).first;

    expect(stored, isNotNull);
    expect(stored!.lines.single.quantity, 2);
    expect(stored.totalCents, 5000);
  });

  test('impide dos órdenes abiertas para la misma mesa', () async {
    await db.into(db.mesasTable).insert(
      MesasTableCompanion.insert(
        id: 'table-1', numeroMesa: '1', createdAt: 1, updatedAt: 1,
      ),
    );
    await repository.openOrder(tableId: 'table-1', serviceType: ServiceType.table);
    expect(
      () => repository.openOrder(
        tableId: 'table-1', serviceType: ServiceType.table,
      ),
      throwsA(isA<StateError>()),
    );
  });
}
