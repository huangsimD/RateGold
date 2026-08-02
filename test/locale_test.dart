import 'package:flutter_test/flutter_test.dart';
import 'package:rategold/l10n/app_language.dart';
import 'package:rategold/l10n/currency_names.dart';

void main() {
  test('CNY localized as Chinese Yuan / 人民币', () {
    expect(CurrencyNames.name('CNY', AppLanguage.en), 'Chinese Yuan');
    expect(CurrencyNames.name('CNY', AppLanguage.zh), '人民币');
  });

  test('all catalog codes have English and Chinese names', () {
    for (final code in CurrencyNames.codes) {
      expect(CurrencyNames.name(code, AppLanguage.en), isNotEmpty);
      expect(CurrencyNames.name(code, AppLanguage.zh), isNotEmpty);
      expect(CurrencyNames.name(code, AppLanguage.en), isNot(code));
    }
  });
}
