import 'package:uuid/uuid.dart';

enum InventoryMovementType { entry, sale, adjustment, cancellation, waste }

extension InventoryMovementValue on InventoryMovementType {
  String get databaseValue => switch (this) {
    InventoryMovementType.entry => 'entrada',
    InventoryMovementType.sale => 'venta',
    InventoryMovementType.adjustment => 'ajuste',
    InventoryMovementType.cancellation => 'cancelacion',
    InventoryMovementType.waste => 'merma',
  };
}

class InventoryMovementRequest {
  InventoryMovementRequest({
    required this.productId,
    required this.quantity,
    required this.type,
    this.referenceId,
    this.notes,
    this.expectedVersion,
    String? idempotencyKey,
  }) : idempotencyKey = idempotencyKey ?? const Uuid().v4();

  final String productId;
  final int quantity;
  final InventoryMovementType type;
  final String? referenceId;
  final String? notes;
  final int? expectedVersion;
  final String idempotencyKey;

  Map<String, Object?> toRpcPayload() => {
    'p_producto_id': productId,
    'p_cantidad': quantity,
    'p_tipo': type.databaseValue,
    'p_idempotency_key': idempotencyKey,
    'p_referencia_id': referenceId,
    'p_notas': notes,
    if (expectedVersion != null) 'p_expected_version': expectedVersion,
  };
}

class InventoryValidationException implements Exception {
  const InventoryValidationException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ProductDraft {
  const ProductDraft({
    this.id,
    required this.name,
    required this.priceCents,
    required this.category,
    required this.tracksInventory,
    required this.minimumStock,
    this.initialStock = 0,
  });
  final String? id;
  final String name;
  final int priceCents;
  final String category;
  final bool tracksInventory;
  final int minimumStock;
  final int initialStock;
}

enum InventorySyncStatus { synced, pendingSync, rejected, requiresReview }

class InventoryCatalogItem {
  const InventoryCatalogItem({required this.product, this.syncStatus = InventorySyncStatus.synced});
  final Object product;
  final InventorySyncStatus syncStatus;
}

class ProductFormRules {
  const ProductFormRules._();
  static String? name(String? value) => value == null || value.trim().length < 2
      ? 'Escribe un nombre de al menos 2 caracteres.'
      : null;
  static String? category(String? value) => value == null || value.trim().isEmpty
      ? 'Selecciona una categoría.'
      : null;
  static String? price(String? value) {
    final parsed = int.tryParse((value ?? '').trim());
    return parsed == null || parsed < 0 ? 'Precio inválido en centavos.' : null;
  }
  static String? stock(String? value) {
    final parsed = int.tryParse((value ?? '').trim());
    return parsed == null || parsed < 0 ? 'Usa una cantidad entera no negativa.' : null;
  }
}

class InventoryRules {
  const InventoryRules._();

  static void validate(
    InventoryMovementRequest request, {
    required bool tracksInventory,
  }) {
    if (request.productId.trim().isEmpty) {
      throw const InventoryValidationException('Producto inválido.');
    }
    if (request.quantity == 0) {
      throw const InventoryValidationException(
        'La cantidad no puede ser cero.',
      );
    }
    final type = request.type;
    if ((type == InventoryMovementType.sale ||
            type == InventoryMovementType.waste) &&
        request.quantity > 0) {
      throw const InventoryValidationException(
        'Venta y merma deben disminuir inventario.',
      );
    }
    if ((type == InventoryMovementType.entry ||
            type == InventoryMovementType.cancellation) &&
        request.quantity < 0) {
      throw const InventoryValidationException(
        'Entrada y cancelación deben aumentar inventario.',
      );
    }
    if (!tracksInventory &&
        (type == InventoryMovementType.sale ||
            type == InventoryMovementType.waste)) {
      throw const InventoryValidationException(
        'El producto no controla inventario.',
      );
    }
  }
}
