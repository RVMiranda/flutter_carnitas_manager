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
/// - Presentación al usuario (formato decimal entero)
abstract final class CurrencyUtils {
  /// Parses decimal input without floating point, rounding, or exponents.
  static int pesosToCentavos(String pesos) {
    final match = RegExp(
      r'^(-?)(\d+)(?:[.,](\d{1,2}))?$',
    ).firstMatch(pesos.trim());
    if (match == null) throw const FormatException('Importe inválido.');
    final cents = int.tryParse(
      '${match[1]}${match[2]}${(match[3] ?? '').padRight(2, '0')}',
    );
    if (cents == null) throw const FormatException('Importe fuera de rango.');
    return cents;
  }

  /// Formatea centavos como string de moneda para mostrar al usuario.
  ///
  /// Ejemplo: 2550 → "\$25.50"
  static String format(int centavos) {
    final text = centavos.toString();
    final negative = text.startsWith('-');
    final digits = (negative ? text.substring(1) : text).padLeft(3, '0');
    final whole = digits
        .substring(0, digits.length - 2)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
    return '${negative ? '-' : ''}\$$whole.${digits.substring(digits.length - 2)}';
  }

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
