import 'package:exquisssita_manager/core/permissions/permission.dart';
import 'package:exquisssita_manager/core/utils/currency_utils.dart';

class EmployeeDraft {
  const EmployeeDraft({this.id, required this.firstName, required this.lastName, required this.phone, required this.salaryPesos, required this.payDay, required this.active});
  final String? id; final String firstName; final String lastName; final String phone; final String salaryPesos; final int payDay; final bool active;
}

class PayrollRules {
  const PayrollRules._();
  static String? name(String? v) => v == null || v.trim().length < 2 ? 'Escribe al menos 2 caracteres.' : null;
  static String? salary(String? v) { try { if (CurrencyUtils.pesosToCentavos(v ?? '') < 0) return 'El salario no puede ser negativo.'; return null; } on FormatException { return 'Ingresa el salario en pesos. Ejemplo: 1000 o 1000.50.'; } }
  static String? payDay(String? v) { final n = int.tryParse(v ?? ''); return n == null || n < 1 || n > 7 ? 'Selecciona un día de lunes a domingo.' : null; }
  static bool isPayDay(DateTime date, int weekday) => date.weekday == weekday;
  static bool canManage(AppRole role) => role.can(Permission.manageEmployees);
}
