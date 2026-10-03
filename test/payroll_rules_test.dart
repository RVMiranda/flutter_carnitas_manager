import 'package:flutter_test/flutter_test.dart';
import 'package:exquisssita_manager/core/permissions/permission.dart';
import 'package:exquisssita_manager/features/employees/domain/payroll_models.dart';

void main() {
  group('PayrollRules', () {
    test('adjusts day 31 in February and short months', () {
      expect(PayrollRules.effectivePayDate(DateTime(2028, 2), 31), DateTime(2028, 2, 29));
      expect(PayrollRules.effectivePayDate(DateTime(2027, 4), 31), DateTime(2027, 4, 30));
    });
    test('validates salary and pay day', () {
      expect(PayrollRules.salary('-1'), isNotNull);
      expect(PayrollRules.payDay('0'), isNotNull);
      expect(PayrollRules.payDay('31'), isNull);
    });
    test('authorization follows employee management permission', () {
      expect(PayrollRules.canManage(AppRole.admin), isTrue);
      expect(PayrollRules.canManage(AppRole.employee), isFalse);
    });
  });
}
