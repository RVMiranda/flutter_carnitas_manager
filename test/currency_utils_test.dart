import 'package:flutter_test/flutter_test.dart';
import 'package:exquisssita_manager/core/utils/currency_utils.dart';

void main() {
  test('money parses and formats exclusively using integer cents', () {
    expect(CurrencyUtils.pesosToCentavos('25.50'), 2550);
    expect(CurrencyUtils.pesosToCentavos('0,01'), 1);
    expect(CurrencyUtils.pesosToCentavos('-0.01'), -1);
    expect(CurrencyUtils.format(9007199254740993), r'$90,071,992,547,409.93');
    expect(CurrencyUtils.format(-1), r'-$0.01');
    expect(
      CurrencyUtils.format(-9223372036854775808),
      r'-$92,233,720,368,547,758.08',
    );
  });
  test('rejects rounding, exponents and values outside signed BIGINT', () {
    for (final value in ['1.001', '1e3', 'NaN', '92233720368547758.08']) {
      expect(() => CurrencyUtils.pesosToCentavos(value), throwsFormatException);
    }
  });
}
