import 'package:exquisssita_manager/core/permissions/permission.dart';

class EmployeeDraft {
  const EmployeeDraft({this.id, required this.firstName, required this.lastName, required this.phone, required this.salaryCents, required this.payDay, required this.active});
  final String? id; final String firstName; final String lastName; final String phone; final int salaryCents; final int payDay; final bool active;
}

class PayrollRules {
  const PayrollRules._();
  static String? name(String? v) => v == null || v.trim().length < 2 ? 'Escribe al menos 2 caracteres.' : null;
  static String? salary(String? v) { final n = int.tryParse(v ?? ''); return n == null || n < 0 ? 'Salario inválido en centavos.' : null; }
  static String? payDay(String? v) { final n = int.tryParse(v ?? ''); return n == null || n < 1 || n > 31 ? 'El día debe estar entre 1 y 31.' : null; }
  static DateTime effectivePayDate(DateTime month, int day) {
    final last = DateTime(month.year, month.month + 1, 0).day;
    final value = day.clamp(1, last);
    return DateTime(month.year, month.month, value);
  }
  static bool canManage(AppRole role) => role.can(Permission.manageEmployees);
}
