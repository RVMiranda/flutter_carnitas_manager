class PaymentPreviewLine {
  const PaymentPreviewLine({
    required this.detailId,
    required this.productName,
    required this.quantity,
    required this.unitPriceCents,
    required this.paidCents,
  });

  final String detailId;
  final String productName;
  final int quantity;
  final int unitPriceCents;
  final int paidCents;

  int get totalCents => quantity * unitPriceCents;
  int get pendingCents => totalCents - paidCents;
}

class PaymentPreview {
  const PaymentPreview({
    required this.orderId,
    required this.lines,
    required this.paidCents,
    this.awaitingConfirmationCents = 0,
    this.requiresReview = false,
  });

  final String orderId;
  final List<PaymentPreviewLine> lines;
  final int paidCents;
  final int awaitingConfirmationCents;
  final bool requiresReview;

  int get totalCents => lines.fold(0, (sum, line) => sum + line.totalCents);
  int get pendingCents => totalCents - paidCents;
  bool get canPay =>
      pendingCents > 0 && awaitingConfirmationCents == 0 && !requiresReview;
}

abstract interface class PaymentPreviewRepository {
  Future<PaymentPreview> preview(String orderId);
}
