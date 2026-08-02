import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:rategold/data/currency_catalog.dart';
import 'package:rategold/data/region_currency_profile.dart';

void main() {
  test('default profile matches global catalog fallback', () {
    expect(
      RegionCurrencyProfile.defaultProfile.baseCurrency,
      CurrencyCatalog.defaultBase,
    );
    expect(
      RegionCurrencyProfile.defaultProfile.favoriteCodes,
      CurrencyCatalog.defaultFavorites,
    );
  });

  test('UAE locale uses AED base and AED to PHP convert defaults', () {
    final profile = RegionCurrencyProfile.forLocale(const Locale('en', 'AE'));
    expect(profile.baseCurrency, 'AED');
    expect(profile.convertFrom, 'AED');
    expect(profile.convertTo, 'PHP');
    expect(profile.favoriteCodes, contains('PHP'));
  });

  test('Philippines locale uses PHP base', () {
    final profile = RegionCurrencyProfile.forLocale(const Locale('en', 'PH'));
    expect(profile.baseCurrency, 'PHP');
    expect(profile.convertFrom, 'PHP');
    expect(profile.convertTo, 'USD');
  });

  test('India locale uses INR base with Gulf remittance favorites', () {
    final profile = RegionCurrencyProfile.forLocale(const Locale('en', 'IN'));
    expect(profile.baseCurrency, 'INR');
    expect(profile.favoriteCodes.first, 'INR');
    expect(profile.favoriteCodes, contains('AED'));
  });

  test('unknown country falls back to global default', () {
    final profile = RegionCurrencyProfile.forLocale(const Locale('en', 'US'));
    expect(profile.baseCurrency, CurrencyCatalog.defaultBase);
  });
}
