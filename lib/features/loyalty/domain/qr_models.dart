class QrCustomerPayload {
  const QrCustomerPayload({required this.token, this.customerId});
  final String token;
  final String? customerId;

  static QrCustomerPayload parse(String raw) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null || uri.scheme != 'exq' || uri.host != 'customer') {
      throw const QrValidationException('Código QR no reconocido.');
    }
    final token = uri.queryParameters['token'];
    if (token == null || token.length < 32 || token.length > 512) {
      throw const QrValidationException('Código QR inválido o incompleto.');
    }
    final customerId = uri.queryParameters['customer_id'];
    if (customerId != null && !_looksLikeUuid(customerId)) {
      throw const QrValidationException('Identificador de cliente inválido.');
    }
    return QrCustomerPayload(token: token, customerId: customerId);
  }

  static bool _looksLikeUuid(String value) => RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  ).hasMatch(value);
}

class QrValidationException implements Exception {
  const QrValidationException(this.message);
  final String message;
  @override
  String toString() => message;
}

class LoyaltyVisitResult {
  const LoyaltyVisitResult({
    required this.registered,
    required this.alreadyRegistered,
    this.pointsAwarded = 0,
  });
  final bool registered;
  final bool alreadyRegistered;
  final int pointsAwarded;
}
