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
    String? idempotencyKey,
  }) : idempotencyKey = idempotencyKey ?? const Uuid().v4();

  final String productId;
  final int quantity;
  final InventoryMovementType type;
  final String? referenceId;
  final String? notes;
  final String idempotencyKey;

  Map<String, Object?> toRpcPayload() => {
    'p_producto_id': productId,
    'p_cantidad': quantity,
    'p_tipo': type.databaseValue,
    'p_idempotency_key': idempotencyKey,
    'p_referencia_id': referenceId,
    'p_notas': notes,
  };
}

class InventoryValidationException implements Exception {
  const InventoryValidationException(this.message);
  final String message;
  @override
  String toString() => message;
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
