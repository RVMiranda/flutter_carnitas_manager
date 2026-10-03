import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:exquisssita_manager/data/local/database/app_database.dart';
import 'package:exquisssita_manager/data/local/database/local_persistence.dart';
import 'package:exquisssita_manager/data/local/tables/sync_queue_table.dart';
import '../domain/inventory_models.dart';

abstract interface class InventoryRepository {
  Future<int> register(InventoryMovementRequest request);
  Stream<List<ProductosTableData>> watchLowStock();
}

class LocalInventoryRepository implements InventoryRepository {
  LocalInventoryRepository(this._database);
  final AppDatabase _database;

  @override
  Stream<List<ProductosTableData>> watchLowStock() =>
      (_database.select(_database.productosTable)..where(
            (p) =>
                p.controlaInventario.equals(true) &
                p.stockActual.isSmallerOrEqual(p.stockMinimo),
          ))
          .watch();

  @override
  Future<int> register(InventoryMovementRequest request) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _database.transaction(() async {
      final product = await (_database.select(
        _database.productosTable,
      )..where((p) => p.id.equals(request.productId))).getSingleOrNull();
      if (product == null) {
        throw const InventoryValidationException('Producto no encontrado.');
      }
      InventoryRules.validate(
        request,
        tracksInventory: product.controlaInventario,
      );
      final newStock = product.stockActual + request.quantity;
      if (newStock < 0) {
        throw const InventoryValidationException('Stock insuficiente.');
      }
      await (_database.update(
        _database.productosTable,
      )..where((p) => p.id.equals(request.productId))).write(
        ProductosTableCompanion(
          stockActual: Value(newStock),
          updatedAt: Value(now),
        ),
      );
      await _database
          .into(_database.movimientosInventarioTable)
          .insert(
            MovimientosInventarioTableCompanion.insert(
              id: const Uuid().v4(),
              productoId: request.productId,
              cantidad: request.quantity,
              tipo: request.type.databaseValue,
              referenciaId: Value(request.referenceId),
              notas: Value(request.notes),
              createdAt: now,
              idempotencyKey: request.idempotencyKey,
            ),
          );
      await _database
          .into(_database.syncQueueTable)
          .insert(
            SyncQueueTableCompanion.insert(
              id: const Uuid().v4(),
              entity: 'registrar_movimiento_inventario',
              entityId: request.productId,
              operation: SyncOperation.insert,
              payload: LocalPersistence.encodePayload(request.toRpcPayload()),
              idempotencyKey: request.idempotencyKey,
              createdAt: now,
            ),
          );
      return newStock;
    });
  }
}
