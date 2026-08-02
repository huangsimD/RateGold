import 'package:rategold/data/gold_market_config.dart';
import 'package:rategold/l10n/app_language.dart';
import 'package:rategold/l10n/currency_names.dart';

/// Supported currencies for V1 (Frankfurter ECB codes + CNY).
abstract final class CurrencyCatalog {
  static const defaultBase = 'USD';

  static const defaultFavorites = ['AED', 'PHP', 'INR', 'IDR', 'CNY'];

  static const goldMarkets = GoldMarketConfig.markets;

  static String nameFor(String code, [AppLanguage language = AppLanguage.en]) {
    return CurrencyNames.name(code, language);
  }

  /// Local gold display unit per market (English default).
  static String goldUnitLabel(String code) => GoldMarketConfig.unitLabel(code);

  static const allCodes = [
    'AED', 'PHP', 'INR', 'IDR', 'SAR', 'CNY', 'EUR', 'GBP', 'SGD',
    'MYR', 'THB', 'BDT', 'PKR', 'NPR', 'LKR',
  ];

  static const baseCurrencyOptions = [
    'USD', 'EUR', 'GBP', 'CNY', 'AED', 'SAR', 'INR', 'PHP', 'IDR', 'SGD', 'MYR',
  ];

  static const maxFavorites = 8;
}
