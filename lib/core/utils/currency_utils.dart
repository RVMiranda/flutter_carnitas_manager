import 'package:intl/intl.dart';

/// Utilidades para operaciones monetarias seguras.
///
/// REGLA FUNDAMENTAL: Todos los valores monetarios se almacenan como
/// enteros (BIGINT) representando CENTAVOS para evitar errores de
/// precisión de punto flotante.
///
/// Ejemplo: $25.50 MXN → 2550 centavos
///
/// Esta estrategia es consistente en:
/// - Base de datos local (Drift: INTEGER)
/// - Base de datos remota (Supabase: BIGINT)
/// - Cálculos en Dart (int)
/// - Presentación al usuario (formato con NumberFormat)
abstract final class CurrencyUtils {
  static final _formatter = NumberFormat.currency(
    locale: 'es_MX',
    symbol: '\$',
    decimalDigits: 2,
  );

  /// Convierte pesos (double del formulario) a centavos (int de almacenamiento).
  ///
  /// Ejemplo: 25.50 → 2550
  static int pesosToCentavos(double pesos) => (pesos * 100).round();

  /// Convierte centavos (int de almacenamiento) a pesos (double para display).
  ///
  /// Ejemplo: 2550 → 25.50
  static double centavosToDouble(int centavos) => centavos / 100.0;

  /// Formatea centavos como string de moneda para mostrar al usuario.
  ///
  /// Ejemplo: 2550 → "\$25.50"
  static String format(int centavos) => _formatter.format(centavos / 100.0);

  /// Suma segura de una lista de valores en centavos.
  ///
  /// Usa reducción entera sin riesgo de error de flotante.
  static int sum(Iterable<int> centavos) =>
      centavos.fold(0, (acc, c) => acc + c);

  /// Calcula el cambio a dar (puede ser negativo si no alcanza).
  ///
  /// [pagado] y [total] en centavos.
  static int cambio({required int pagado, required int total}) =>
      pagado - total;

  /// Verifica que un pago no exceda el total pendiente.
  static bool excedePendiente({
    required int montoPagado,
    required int totalPendiente,
  }) => montoPagado > totalPendiente;

  /// Divide un total en N partes iguales, distribuyendo el centavo residual.
  ///
  /// Ejemplo: 100 centavos ÷ 3 → [34, 33, 33]
  static List<int> dividirEnPartes(int totalCentavos, int partes) {
    if (partes <= 0) throw ArgumentError('partes debe ser > 0');
    final base = totalCentavos ~/ partes;
    final residuo = totalCentavos % partes;
    return List.generate(partes, (i) => i < residuo ? base + 1 : base);
  }
}
