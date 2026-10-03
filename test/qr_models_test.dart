import 'package:flutter_test/flutter_test.dart';
import 'package:exquisssita_manager/features/loyalty/domain/qr_models.dart';

void main() {
  const token = 'abcdefghijklmnopqrstuvwxyz123456';

  test('acepta únicamente el formato QR de cliente esperado', () {
    final payload = QrCustomerPayload.parse(
      'exq://customer?token=$token&customer_id=550e8400-e29b-41d4-a716-446655440000',
    );
    expect(payload.token, token);
  });

  test('rechaza QR que no contiene token opaco válido', () {
    expect(
      () => QrCustomerPayload.parse('https://example.com/customer?token=short'),
      throwsA(isA<QrValidationException>()),
    );
  });
}
