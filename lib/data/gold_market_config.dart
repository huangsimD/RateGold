import 'package:intl/intl.dart';

/// Regional gold display rules for V1 markets (PRD D8).
abstract final class GoldMarketConfig {
  static const markets = ['INR', 'AED', 'SAR', 'PHP', 'IDR'];

  /// Grams of fine gold represented by the displayed price.
  static double unitGrams(String code) {
    return switch (code) {
      'INR' => 10.0,
      _ => 1.0,
    };
  }

  static String unitLabel(String code) {
    return switch (code) {
      'INR' => '24K / 10g',
      'AED' => '24K / g',
      'SAR' => '24K / g',
      'PHP' => '24K / g',
      'IDR' => '24K / g',
      _ => '24K / g',
    };
  }

  /// Converts USD/gram spot into local price for the market unit.
  static double localPrice({
    required String code,
    required double usdPerGram,
    required double fxRate,
  }) {
    return usdPerGram * fxRate * unitGrams(code);
  }

  static String formatPrice(String code, double localPrice) {
    return switch (code) {
      'INR' => _formatInr(localPrice),
      'IDR' => _formatIdr(localPrice),
      'PHP' => _formatPhp(localPrice),
      'AED' => _formatGulf(localPrice),
      'SAR' => _formatGulf(localPrice),
      _ => NumberFormat('#,##0.00', 'en_US').format(localPrice),
    };
  }

  static String _formatInr(double value) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(value);
  }

  static String _formatIdr(double value) {
    return NumberFormat.decimalPattern('id_ID').format(value.round());
  }

  static String _formatPhp(double value) {
    if (value >= 1000) {
      return NumberFormat('#,##0', 'en_US').format(value.round());
    }
    return NumberFormat('#,##0.00', 'en_US').format(value);
  }

  static String _formatGulf(double value) {
    return NumberFormat('#,##0.00', 'en_US').format(value);
  }
}
