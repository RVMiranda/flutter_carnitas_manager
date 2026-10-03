import 'payment_preview.dart';

class PreviewPaymentUseCase {
  const PreviewPaymentUseCase(this._repository);
  final PaymentPreviewRepository _repository;

  Future<PaymentPreview> call(String orderId) {
    if (orderId.trim().isEmpty) {
      throw ArgumentError.value(orderId, 'orderId', 'No puede estar vacío');
    }
    return _repository.preview(orderId);
  }
}
