import 'package:flutter_test/flutter_test.dart';
import 'package:exquisssita_manager/features/cash_register/domain/cash_register_models.dart';

void main() {
  test('el resumen conserva importes en centavos y estado de cierre', () {
    final summary = CashRegisterSummary(
      date: DateTime(2026),
      cashCents: 12500,
      cardCents: 5000,
      otherCents: 2500,
      totalCents: 20000,
      orderCount: 4,
    );
    expect(summary.totalCents, 20000);
    expect(summary.orderCount, 4);
    expect(summary.closed, isFalse);
  });

  test('el cierre conserva la fecha del negocio y la hora de cierre', () {
    final closure = CashRegisterClosure(
      date: DateTime(2026, 10, 2),
      cashCents: 100,
      cardCents: 200,
      otherCents: 0,
      totalCents: 300,
      orderCount: 2,
      closedAt: DateTime(2026, 10, 2, 22),
    );
    expect(closure.date.day, 2);
    expect(closure.closedAt.hour, 22);
    expect(closure.totalCents, 300);
  });
}
