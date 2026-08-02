import 'package:intl/intl.dart';
import 'package:rategold/data/currency_catalog.dart';
import 'package:rategold/data/gold_market_config.dart';
import 'package:rategold/models/currency_rate.dart';
import 'package:rategold/models/gold_quote.dart';
import 'package:rategold/models/rates_snapshot.dart';

abstract final class GoldCalculator {
  static const troyOzToGrams = 31.1034768;

  static List<GoldQuote> buildQuotes({
    required GoldSnapshot gold,
    required RatesSnapshot rates,
    required List<String> markets,
  }) {
    final usdPerGram = gold.usdPerOz / troyOzToGrams;
    final stale = DateTime.now().difference(gold.updatedAt).inHours >= 24;

    return [
      for (final code in markets)
        _quoteForMarket(
          code: code,
          usdPerGram: usdPerGram,
          rates: rates,
          stale: stale,
        ),
    ].whereType<GoldQuote>().toList();
  }

  static GoldQuote? _quoteForMarket({
    required String code,
    required double usdPerGram,
    required RatesSnapshot rates,
    required bool stale,
  }) {
    final fx = rates.rateFor(code);
    if (fx == null) return null;

    final localPrice = GoldMarketConfig.localPrice(
      code: code,
      usdPerGram: usdPerGram,
      fxRate: fx,
    );

    return GoldQuote(
      marketCode: code,
      marketLabel: code,
      unitLabel: GoldMarketConfig.unitLabel(code),
      priceDisplay: GoldMarketConfig.formatPrice(code, localPrice),
      isStale: stale,
    );
  }

  static List<CurrencyRate> buildRateList({
    required RatesSnapshot snapshot,
    required List<String> favoriteCodes,
  }) {
    return [
      for (final code in favoriteCodes)
        _rateFor(snapshot, code),
    ].whereType<CurrencyRate>().toList();
  }

  static CurrencyRate? _rateFor(RatesSnapshot snapshot, String code) {
    final value = snapshot.rateFor(code);
    if (value == null) return null;

    return CurrencyRate(
      code: code,
      name: CurrencyCatalog.nameFor(code),
      rateValue: value,
      rateDisplay: _formatRate(value, code),
    );
  }

  static String _formatRate(double value, String code) {
    if (code == 'IDR') {
      return NumberFormat.decimalPattern('en_US').format(value.round());
    }
    if (value >= 100) {
      return NumberFormat('#,##0.##', 'en_US').format(value);
    }
    return NumberFormat('#,##0.0000', 'en_US').format(value);
  }
}
