import 'dart:ui';

import 'package:rategold/data/currency_catalog.dart';

/// First-launch defaults tuned for SEA / South Asia / Gulf markets.
class RegionCurrencyProfile {
  const RegionCurrencyProfile({
    required this.baseCurrency,
    required this.favoriteCodes,
    required this.convertFrom,
    required this.convertTo,
    this.defaultConvertAmount = 500,
  });

  final String baseCurrency;
  final List<String> favoriteCodes;
  final String convertFrom;
  final String convertTo;
  final double defaultConvertAmount;

  static const defaultProfile = RegionCurrencyProfile(
    baseCurrency: CurrencyCatalog.defaultBase,
    favoriteCodes: CurrencyCatalog.defaultFavorites,
    convertFrom: 'AED',
    convertTo: 'PHP',
  );

  static const Map<String, RegionCurrencyProfile> _byCountry = {
    'AE': RegionCurrencyProfile(
      baseCurrency: 'AED',
      favoriteCodes: ['AED', 'PHP', 'INR', 'USD', 'SAR', 'IDR'],
      convertFrom: 'AED',
      convertTo: 'PHP',
    ),
    'SA': RegionCurrencyProfile(
      baseCurrency: 'SAR',
      favoriteCodes: ['SAR', 'PHP', 'INR', 'AED', 'USD', 'IDR'],
      convertFrom: 'SAR',
      convertTo: 'PHP',
    ),
    'PH': RegionCurrencyProfile(
      baseCurrency: 'PHP',
      favoriteCodes: ['PHP', 'USD', 'AED', 'SGD', 'SAR', 'INR'],
      convertFrom: 'PHP',
      convertTo: 'USD',
      defaultConvertAmount: 1000,
    ),
    'ID': RegionCurrencyProfile(
      baseCurrency: 'IDR',
      favoriteCodes: ['IDR', 'USD', 'SGD', 'MYR', 'AED', 'SAR'],
      convertFrom: 'IDR',
      convertTo: 'USD',
      defaultConvertAmount: 1000000,
    ),
    'IN': RegionCurrencyProfile(
      baseCurrency: 'INR',
      favoriteCodes: ['INR', 'AED', 'USD', 'SAR', 'PHP', 'SGD'],
      convertFrom: 'INR',
      convertTo: 'USD',
      defaultConvertAmount: 1000,
    ),
    'BD': RegionCurrencyProfile(
      baseCurrency: 'BDT',
      favoriteCodes: ['BDT', 'AED', 'USD', 'SAR', 'INR', 'MYR'],
      convertFrom: 'BDT',
      convertTo: 'AED',
      defaultConvertAmount: 1000,
    ),
    'MY': RegionCurrencyProfile(
      baseCurrency: 'MYR',
      favoriteCodes: ['MYR', 'USD', 'SGD', 'IDR', 'AED', 'INR'],
      convertFrom: 'MYR',
      convertTo: 'USD',
      defaultConvertAmount: 500,
    ),
    'SG': RegionCurrencyProfile(
      baseCurrency: 'SGD',
      favoriteCodes: ['SGD', 'USD', 'MYR', 'IDR', 'AED', 'INR'],
      convertFrom: 'SGD',
      convertTo: 'USD',
      defaultConvertAmount: 500,
    ),
    'PK': RegionCurrencyProfile(
      baseCurrency: 'PKR',
      favoriteCodes: ['PKR', 'AED', 'USD', 'SAR', 'INR', 'BDT'],
      convertFrom: 'PKR',
      convertTo: 'AED',
      defaultConvertAmount: 1000,
    ),
    'NP': RegionCurrencyProfile(
      baseCurrency: 'NPR',
      favoriteCodes: ['NPR', 'AED', 'USD', 'SAR', 'INR', 'BDT'],
      convertFrom: 'NPR',
      convertTo: 'AED',
      defaultConvertAmount: 1000,
    ),
    'LK': RegionCurrencyProfile(
      baseCurrency: 'LKR',
      favoriteCodes: ['LKR', 'AED', 'USD', 'SAR', 'INR', 'SGD'],
      convertFrom: 'LKR',
      convertTo: 'AED',
      defaultConvertAmount: 1000,
    ),
    'TH': RegionCurrencyProfile(
      baseCurrency: 'THB',
      favoriteCodes: ['THB', 'USD', 'SGD', 'MYR', 'AED', 'INR'],
      convertFrom: 'THB',
      convertTo: 'USD',
      defaultConvertAmount: 1000,
    ),
    'CN': RegionCurrencyProfile(
      baseCurrency: 'CNY',
      favoriteCodes: ['CNY', 'USD', 'AED', 'PHP', 'INR', 'SGD'],
      convertFrom: 'CNY',
      convertTo: 'USD',
      defaultConvertAmount: 500,
    ),
  };

  static RegionCurrencyProfile forLocale(Locale locale) {
    final country = locale.countryCode?.toUpperCase();
    if (country == null || country.isEmpty) return defaultProfile;
    return _byCountry[country] ?? defaultProfile;
  }
}
