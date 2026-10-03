import 'package:flutter_test/flutter_test.dart';
import 'package:exquisssita_manager/features/payments/domain/payment_preview.dart';

void main() {
  test('calcula total y saldo pendiente usando centavos', () {
    const preview = PaymentPreview(
      orderId: 'order-1',
      paidCents: 500,
      lines: [
        PaymentPreviewLine(
          detailId: 'detail-1',
          productName: 'Taco',
          quantity: 2,
          unitPriceCents: 350,
          paidCents: 300,
        ),
      ],
    );

    expect(preview.totalCents, 700);
    expect(preview.pendingCents, 200);
    expect(preview.canPay, isTrue);
  });
}
