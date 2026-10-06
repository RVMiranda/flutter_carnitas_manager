import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

import 'package:exquisssita_manager/data/local/database/app_database.dart';
import 'package:exquisssita_manager/data/local/database/local_persistence.dart';
import 'package:exquisssita_manager/data/local/tables/sync_queue_table.dart';
import '../domain/inventory_models.dart';
import '../../../data/sync/critical_operation_repository.dart';

abstract interface class InventoryRepository {
  Stream<List<ProductosTableData>> watchProducts({
    String query = '',
    String? category,
    bool? controlled,
  });
  Future<String> saveProduct(ProductDraft draft);
  Future<void> deactivateProduct(String productId);
  Stream<List<MovimientosInventarioTableData>> watchMovements(String productId);
  Future<int> register(InventoryMovementRequest request);
  Future<int> compensate(String movementId, {required String idempotencyKey});
  Stream<List<ProductosTableData>> watchLowStock();
}

class LocalInventoryRepository implements InventoryRepository {
  LocalInventoryRepository(this._database);
  final AppDatabase _database;

  @override
  Stream<List<ProductosTableData>> watchProducts({
    String query = '',
    String? category,
    bool? controlled,
  }) {
    final q = query.trim().toLowerCase();
    final statement = _database.select(_database.productosTable)
      ..where((p) => p.activo.equals(true));
    return statement.watch().map(
      (rows) => rows.where((p) {
        final matchesQuery =
            q.isEmpty ||
            p.nombre.toLowerCase().contains(q) ||
            p.categoria.toLowerCase().contains(q);
        final matchesCategory =
            category == null || category.isEmpty || p.categoria == category;
        final matchesControl =
            controlled == null || p.controlaInventario == controlled;
        return matchesQuery && matchesCategory && matchesControl;
      }).toList(),
    );
  }

  @override
  Future<String> saveProduct(ProductDraft draft) async {
    final name = draft.name.trim();
    final category = draft.category.trim();
    if (ProductFormRules.name(name) != null ||
        ProductFormRules.category(category) != null ||
        ProductFormRules.price('${draft.priceCents}') != null ||
        ProductFormRules.stock('${draft.minimumStock}') != null ||
        draft.initialStock < 0) {
      throw const InventoryValidationException(
        'Los datos del producto no son válidos.',
      );
    }
    final id = draft.id ?? const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    await _database.transaction(() async {
      final existing = await (_database.select(
        _database.productosTable,
      )..where((p) => p.id.equals(id))).getSingleOrNull();
      await _database
          .into(_database.productosTable)
          .insertOnConflictUpdate(
            ProductosTableCompanion(
              id: Value(id),
              nombre: Value(name),
              precioCentavos: Value(draft.priceCents),
              categoria: Value(category),
              controlaInventario: Value(draft.tracksInventory),
              stockActual: existing == null
                  ? const Value(0)
                  : Value(existing.stockActual),
              stockMinimo: Value(
                draft.tracksInventory ? draft.minimumStock : 0,
              ),
              activo: const Value(true),
              createdAt: Value(existing?.createdAt ?? now),
              updatedAt: Value(now),
            ),
          );
      await (_database.delete(_database.syncQueueTable)..where(
            (entry) =>
                entry.entity.equals('productos') & entry.entityId.equals(id),
          ))
          .go();
      await _database
          .into(_database.syncQueueTable)
          .insert(
            SyncQueueTableCompanion.insert(
              id: const Uuid().v4(),
              entity: 'productos',
              entityId: id,
              operation: draft.id == null
                  ? SyncOperation.insert
                  : SyncOperation.update,
              payload: LocalPersistence.encodePayload({
                'id': id,
                'nombre': name,
                // Remote public.productos uses `precio`; local Drift uses
                // `precio_centavos` for clarity.
                'precio': draft.priceCents,
                'categoria': category,
                'controla_inventario': draft.tracksInventory,
                'stock_minimo': draft.minimumStock,
                'activo': true,
              }),
              idempotencyKey: const Uuid().v4(),
              createdAt: now,
            ),
          );
      if (existing == null && draft.tracksInventory && draft.initialStock > 0) {
        await register(
          InventoryMovementRequest(
            productId: id,
            quantity: draft.initialStock,
            type: InventoryMovementType.entry,
            notes: 'Existencia inicial',
          ),
        );
      }
    });
    return id;
  }

  @override
  Future<void> deactivateProduct(String productId) async {
    await (_database.update(
      _database.productosTable,
    )..where((p) => p.id.equals(productId))).write(
      ProductosTableCompanion(
        activo: const Value(false),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  @override
  Stream<List<MovimientosInventarioTableData>> watchMovements(
    String productId,
  ) => (_database.select(
    _database.movimientosInventarioTable,
  )..where((m) => m.productoId.equals(productId))).watch();

  @override
  Future<int> compensate(
    String movementId, {
    required String idempotencyKey,
  }) async {
    final original = await (_database.select(
      _database.movimientosInventarioTable,
    )..where((m) => m.id.equals(movementId))).getSingleOrNull();
    if (original == null || original.cantidad >= 0) {
      throw const InventoryValidationException(
        'El movimiento original no admite devolución.',
      );
    }
    final confirmed = await _database
        .customSelect(
          "SELECT 1 FROM sync_entity_state WHERE entity='movimientos_inventario' AND entity_id=? AND deleted=0",
          variables: [Variable(movementId)],
        )
        .getSingleOrNull();
    if (confirmed == null) {
      throw const InventoryValidationException(
        'Confirma el movimiento antes de compensarlo.',
      );
    }
    return register(
      InventoryMovementRequest(
        productId: original.productoId,
        quantity: -original.cantidad,
        type: InventoryMovementType.cancellation,
        referenceId: movementId,
        idempotencyKey: idempotencyKey,
      ),
    );
  }

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
      final payload = LocalPersistence.encodePayload(request.toRpcPayload());
      final previous =
          await (_database.select(_database.syncQueueTable)
                ..where((t) => t.idempotencyKey.equals(request.idempotencyKey)))
              .getSingleOrNull();
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
      if (request.type == InventoryMovementType.adjustment &&
          request.expectedVersion == null) {
        throw const InventoryValidationException(
          'Actualiza el producto antes de ajustar su inventario.',
        );
      }
      final reservation = await CriticalOperationRepository(
        _database,
      ).reservedDelta(request.productId);
      final available = product.stockActual + reservation.clamp(-2147483648, 0);
      if (previous != null) {
        if (previous.entity != 'registrar_movimiento_inventario' ||
            previous.payload != payload) {
          throw const InventoryValidationException(
            'El identificador ya fue utilizado.',
          );
        }
        return available;
      }
      final newStock = available + request.quantity;
      if (newStock < 0) {
        throw const InventoryValidationException('Stock insuficiente.');
      }
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
      return request.quantity < 0 ? newStock : available;
    });
  }
}
