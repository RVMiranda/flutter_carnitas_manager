import 'package:flutter_test/flutter_test.dart';
import 'package:exquisssita_manager/core/permissions/permission.dart';

void main() {
  test('admin tiene acceso a todas las capacidades', () {
    for (final permission in Permission.values) {
      expect(AppRole.admin.can(permission), isTrue);
    }
  });

  test('empleado no puede gestionar empleados, promociones ni caja', () {
    expect(AppRole.employee.can(Permission.manageEmployees), isFalse);
    expect(AppRole.employee.can(Permission.managePromotions), isFalse);
    expect(AppRole.employee.can(Permission.closeCashRegister), isFalse);
    expect(AppRole.employee.can(Permission.manageOrders), isTrue);
  });
}
