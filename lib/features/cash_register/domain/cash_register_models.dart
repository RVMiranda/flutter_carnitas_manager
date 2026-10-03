class CashRegisterSummary {
  const CashRegisterSummary({
    required this.date,
    required this.cashCents,
    required this.cardCents,
    required this.otherCents,
    required this.totalCents,
    required this.orderCount,
    this.closed = false,
  });
  final DateTime date;
  final int cashCents;
  final int cardCents;
  final int otherCents;
  final int totalCents;
  final int orderCount;
  final bool closed;
}

abstract interface class CashRegisterRepository {
  Stream<CashRegisterSummary> watchSummary(DateTime date);
  Future<CashRegisterSummary> close(DateTime date);
}
