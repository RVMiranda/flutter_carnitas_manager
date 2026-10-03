import 'package:flutter_test/flutter_test.dart';
import 'package:exquisssita_manager/features/inventory/domain/inventory_models.dart';

void main() {
  test('venta y merma siempre reducen inventario', () {
    final request = InventoryMovementRequest(
      productId: 'product-1',
      quantity: -2,
      type: InventoryMovementType.sale,
    );
    expect(
      () => InventoryRules.validate(request, tracksInventory: true),
      returnsNormally,
    );
    expect(request.toRpcPayload()['p_tipo'], 'venta');
  });

  test('rechaza stock negativo', () {
    final request = InventoryMovementRequest(
      productId: 'product-1',
      quantity: 2,
      type: InventoryMovementType.sale,
    );
    expect(
      () => InventoryRules.validate(request, tracksInventory: true),
      throwsA(isA<InventoryValidationException>()),
    );
  });

  test('rechaza venta de producto sin inventario controlado', () {
    final request = InventoryMovementRequest(
      productId: 'product-1',
      quantity: -1,
      type: InventoryMovementType.waste,
    );
    expect(
      () => InventoryRules.validate(request, tracksInventory: false),
      throwsA(isA<InventoryValidationException>()),
    );
  });
}
