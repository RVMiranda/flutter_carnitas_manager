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

class CashRegisterClosure {
  const CashRegisterClosure({
    required this.date,
    required this.cashCents,
    required this.cardCents,
    required this.otherCents,
    required this.totalCents,
    required this.orderCount,
    required this.closedAt,
  });

  final DateTime date;
  final int cashCents;
  final int cardCents;
  final int otherCents;
  final int totalCents;
  final int orderCount;
  final DateTime closedAt;
}

abstract interface class CashRegisterRepository {
  Stream<CashRegisterSummary> watchSummary(DateTime date);
  Stream<List<CashRegisterClosure>> watchClosures();
  Future<CashRegisterSummary> close(DateTime date);
}
