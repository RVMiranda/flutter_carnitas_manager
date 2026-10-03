import '../data/loyalty_repository.dart';
import '../domain/qr_models.dart';

class QrScanCoordinator {
  QrScanCoordinator(this._repository);
  final LoyaltyRepository _repository;
  bool _processing = false;

  Future<LoyaltyVisitResult> handle(String rawCode) async {
    if (_processing) {
      throw const QrValidationException('Ya se está procesando un código.');
    }
    _processing = true;
    try {
      final payload = QrCustomerPayload.parse(rawCode);
      return await _repository.registerVisit(payload);
    } finally {
      _processing = false;
    }
  }
}
