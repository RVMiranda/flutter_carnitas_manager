import 'package:flutter_test/flutter_test.dart';
import 'package:exquisssita_manager/features/payments/domain/payment_models.dart';
import 'package:exquisssita_manager/features/payments/domain/payment_preview.dart';

PaymentPreview preview() => const PaymentPreview(
  orderId: 'order-1',
  paidCents: 0,
  lines: [
    PaymentPreviewLine(
      detailId: 'detail-1',
      productName: 'Taco',
      quantity: 2,
      unitPriceCents: 1000,
      paidCents: 0,
    ),
    PaymentPreviewLine(
      detailId: 'detail-2',
      productName: 'Agua',
      quantity: 1,
      unitPriceCents: 2000,
      paidCents: 0,
    ),
  ],
);

void main() {
  test('pago completo asigna todos los detalles pendientes', () {
    final request = PaymentAllocationCalculator.full(
      preview(),
      PaymentMethod.cash,
    );
    expect(request.amountCents, 4000);
    expect(request.allocations, hasLength(2));
  });

  test('pago por cantidad calcula el subtotal correcto', () {
    final request = PaymentAllocationCalculator.byQuantity(
      preview(),
      PaymentMethod.card,
      'detail-1',
      1,
    );
    expect(request.amountCents, 1000);
    expect(request.allocations.single.quantity, 1);
  });

  test('pago por monto rechaza exceder el saldo', () {
    expect(
      () => PaymentAllocationCalculator.byAmount(
        preview(),
        PaymentMethod.transfer,
        4001,
      ),
      throwsA(isA<PaymentValidationException>()),
    );
  });

  test('método de pago se serializa con el valor del backend', () {
    final request = PaymentAllocationCalculator.byQuantity(
      preview(),
      PaymentMethod.card,
      'detail-1',
      1,
    );
    expect(request.toRpcPayload()['p_metodo_pago'], 'Tarjeta');
    expect(request.toRpcPayload()['p_idempotency_key'], isA<String>());
  });
}
