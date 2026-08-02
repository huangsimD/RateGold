import 'package:flutter_test/flutter_test.dart';
import 'package:rategold/data/gold_market_config.dart';
import 'package:rategold/models/rates_snapshot.dart';
import 'package:rategold/services/gold_calculator.dart';

final _testTime = DateTime(2026, 7, 4);
const _usdPerOz = 2350.0;

RatesSnapshot _rates(Map<String, double> rates) {
  return RatesSnapshot(
    base: 'USD',
    date: '2026-07-04',
    rates: rates,
    fetchedAt: _testTime,
  );
}

GoldSnapshot _gold() {
  return GoldSnapshot(
    usdPerOz: _usdPerOz,
    updatedAt: _testTime,
    source: 'test',
  );
}

double _usdPerGram() => _usdPerOz / GoldCalculator.troyOzToGrams;

void main() {
  test('INR quote is per 10g with rupee symbol', () {
    const fx = 83.0;
    final expected = GoldMarketConfig.formatPrice(
      'INR',
      GoldMarketConfig.localPrice(
        code: 'INR',
        usdPerGram: _usdPerGram(),
        fxRate: fx,
      ),
    );

    final quotes = GoldCalculator.buildQuotes(
      gold: _gold(),
      rates: _rates({'INR': fx}),
      markets: ['INR'],
    );

    expect(quotes, hasLength(1));
    expect(quotes.first.unitLabel, '24K / 10g');
    expect(quotes.first.priceDisplay, expected);
    expect(quotes.first.priceDisplay, startsWith('₹'));
  });

  test('AED and SAR quotes are per gram with two decimals', () {
    const aedFx = 3.6725;
    const sarFx = 3.75;
    final aedExpected = GoldMarketConfig.formatPrice(
      'AED',
      GoldMarketConfig.localPrice(
        code: 'AED',
        usdPerGram: _usdPerGram(),
        fxRate: aedFx,
      ),
    );
    final sarExpected = GoldMarketConfig.formatPrice(
      'SAR',
      GoldMarketConfig.localPrice(
        code: 'SAR',
        usdPerGram: _usdPerGram(),
        fxRate: sarFx,
      ),
    );

    final quotes = GoldCalculator.buildQuotes(
      gold: _gold(),
      rates: _rates({'AED': aedFx, 'SAR': sarFx}),
      markets: ['AED', 'SAR'],
    );

    expect(quotes[0].unitLabel, '24K / g');
    expect(quotes[0].priceDisplay, aedExpected);
    expect(quotes[0].priceDisplay, matches(RegExp(r'^\d+\.\d{2}$')));
    expect(quotes[1].priceDisplay, sarExpected);
  });

  test('PHP quote rounds to whole peso for large values', () {
    const fx = 56.24;
    final local = GoldMarketConfig.localPrice(
      code: 'PHP',
      usdPerGram: _usdPerGram(),
      fxRate: fx,
    );

    final quotes = GoldCalculator.buildQuotes(
      gold: _gold(),
      rates: _rates({'PHP': fx}),
      markets: ['PHP'],
    );

    expect(quotes.first.unitLabel, '24K / g');
    expect(quotes.first.priceDisplay, GoldMarketConfig.formatPrice('PHP', local));
    expect(quotes.first.priceDisplay, isNot(contains('.')));
  });

  test('IDR quote uses Indonesian grouping without decimals', () {
    const fx = 15840.0;
    final local = GoldMarketConfig.localPrice(
      code: 'IDR',
      usdPerGram: _usdPerGram(),
      fxRate: fx,
    );

    final quotes = GoldCalculator.buildQuotes(
      gold: _gold(),
      rates: _rates({'IDR': fx}),
      markets: ['IDR'],
    );

    expect(quotes.first.unitLabel, '24K / g');
    expect(quotes.first.priceDisplay, GoldMarketConfig.formatPrice('IDR', local));
    expect(quotes.first.priceDisplay, isNot(contains(',')));
  });

  test('buildQuotes includes all five PRD gold markets when FX available', () {
    final quotes = GoldCalculator.buildQuotes(
      gold: _gold(),
      rates: _rates({
        'INR': 83.0,
        'AED': 3.6725,
        'SAR': 3.75,
        'PHP': 56.24,
        'IDR': 15840,
      }),
      markets: GoldMarketConfig.markets,
    );

    expect(quotes.map((q) => q.marketCode).toList(), GoldMarketConfig.markets);
  });

  test('GoldMarketConfig unitGrams matches PRD markets', () {
    expect(GoldMarketConfig.unitGrams('INR'), 10.0);
    expect(GoldMarketConfig.unitGrams('AED'), 1.0);
    expect(GoldMarketConfig.markets, ['INR', 'AED', 'SAR', 'PHP', 'IDR']);
  });

  test('buildRateList formats favorite currencies', () {
    final snapshot = _rates({'AED': 3.6725, 'PHP': 56.24});

    final list = GoldCalculator.buildRateList(
      snapshot: snapshot,
      favoriteCodes: ['AED', 'PHP'],
    );

    expect(list.map((r) => r.code).toList(), ['AED', 'PHP']);
    expect(list.first.rateDisplay, '3.6725');
  });
}
