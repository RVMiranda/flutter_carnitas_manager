import 'package:exquisssita_manager/core/permissions/permission.dart';
import 'package:exquisssita_manager/core/utils/currency_utils.dart';

class EmployeeDraft {
  const EmployeeDraft({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.salaryPesos,
    required this.payDay,
    required this.active,
  });
  final String? id;
  final String firstName;
  final String lastName;
  final String phone;
  final String salaryPesos;
  final int payDay;
  final bool active;
}

class PayrollRules {
  const PayrollRules._();
  static String? name(String? v) => v == null || v.trim().length < 2
      ? 'Escribe al menos 2 caracteres.'
      : null;
  static String? salary(String? v) {
    try {
      if (CurrencyUtils.pesosToCentavos(v ?? '') <= 0) {
        return 'El salario debe ser mayor a cero.';
      }
      return null;
    } on FormatException {
      return 'Ingresa el salario en pesos. Ejemplo: 1000 o 1000.50.';
    }
  }

  static String? payDay(String? v) {
    final n = int.tryParse(v ?? '');
    return n == null || n < 1 || n > 7
        ? 'Selecciona un día de lunes a domingo.'
        : null;
  }

  static bool isPayDay(DateTime date, int weekday) => date.weekday == weekday;
  static bool canManage(AppRole role) => role.can(Permission.manageEmployees);
}

/// A payroll week runs from Monday through Sunday. The Thursday determines
/// which month owns a week that crosses a month boundary.
abstract final class PayrollWeek {
  static const _months = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  static DateTime startOf(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  static DateTime scheduledDate(DateTime weekStart, int payDay) {
    if (payDay < 1 || payDay > 7) throw RangeError.range(payDay, 1, 7);
    return startOf(weekStart).add(Duration(days: payDay - 1));
  }

  static String dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static String dateLabel(DateTime date) =>
      '${date.day} de ${_months[date.month - 1]} de ${date.year}';

  static String monthLabel(DateTime date) =>
      '${_months[date.month - 1]} de ${date.year}';

  static String label(DateTime weekStart) {
    final monday = startOf(weekStart);
    final thursday = monday.add(const Duration(days: 3));
    final number = ((thursday.day - 1) ~/ 7) + 1;
    return 'Semana $number de ${_months[thursday.month - 1]} de ${thursday.year}';
  }

  static String rangeLabel(DateTime weekStart) {
    final monday = startOf(weekStart);
    final sunday = monday.add(const Duration(days: 6));
    return '${monday.day} ${_months[monday.month - 1]} – ${sunday.day} ${_months[sunday.month - 1]}';
  }
}
