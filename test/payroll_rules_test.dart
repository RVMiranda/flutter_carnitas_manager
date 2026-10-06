import 'package:flutter_test/flutter_test.dart';
import 'package:exquisssita_manager/core/permissions/permission.dart';
import 'package:exquisssita_manager/features/employees/domain/payroll_models.dart';

void main() {
  group('PayrollRules', () {
    test('recognizes weekly paydays from Monday to Sunday', () {
      expect(PayrollRules.isPayDay(DateTime(2026, 10, 5), 1), isTrue);
      expect(PayrollRules.isPayDay(DateTime(2026, 10, 5), 7), isFalse);
    });
    test('keeps payment week distinct from actual payment date', () {
      final week = PayrollWeek.startOf(DateTime(2026, 10, 4));
      expect(PayrollWeek.dateKey(week), '2026-09-28');
      expect(PayrollWeek.label(week), 'Semana 1 de octubre de 2026');
      expect(
        PayrollWeek.dateKey(PayrollWeek.scheduledDate(week, 3)),
        '2026-09-30',
      );
    });
    test('validates salary and pay day', () {
      expect(PayrollRules.salary('-1'), isNotNull);
      expect(PayrollRules.payDay('0'), isNotNull);
      expect(PayrollRules.salary('1000'), isNull);
      expect(PayrollRules.salary('1000.50'), isNull);
      expect(PayrollRules.payDay('7'), isNull);
      expect(PayrollRules.payDay('8'), isNotNull);
    });
    test('authorization follows employee management permission', () {
      expect(PayrollRules.canManage(AppRole.admin), isTrue);
      expect(PayrollRules.canManage(AppRole.employee), isFalse);
    });
  });
}
