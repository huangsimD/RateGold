import 'package:intl/intl.dart';
import 'package:rategold/models/rates_snapshot.dart';

class ConversionResult {
  const ConversionResult({
    required this.amount,
    required this.fromCode,
    required this.toCode,
    required this.result,
    required this.crossRate,
  });

  final double amount;
  final String fromCode;
  final String toCode;
  final double result;
  /// Units of [toCode] per 1 [fromCode].
  final double crossRate;
}

abstract final class ConversionService {
  static ConversionResult? convert({
    required RatesSnapshot snapshot,
    required double amount,
    required String fromCode,
    required String toCode,
  }) {
    if (amount.isNaN || amount.isInfinite || amount < 0) return null;

    final fromRate = snapshot.rateFor(fromCode);
    final toRate = snapshot.rateFor(toCode);
    if (fromRate == null || toRate == null) return null;

    final amountInBase = fromCode == snapshot.base
        ? amount
        : amount / fromRate;
    final result = toCode == snapshot.base
        ? amountInBase
        : amountInBase * toRate;

    final crossRate = fromCode == snapshot.base
        ? toRate
        : toCode == snapshot.base
            ? 1 / fromRate
            : toRate / fromRate;

    return ConversionResult(
      amount: amount,
      fromCode: fromCode,
      toCode: toCode,
      result: result,
      crossRate: crossRate,
    );
  }

  static String formatAmount(double value, String code) {
    if (code == 'IDR') {
      return NumberFormat.decimalPattern('en_US').format(value.round());
    }
    if (value >= 1000) {
      return NumberFormat('#,##0.00', 'en_US').format(value);
    }
    return NumberFormat('#,##0.00', 'en_US').format(value);
  }

  static String formatCrossRate(double rate, String fromCode, String toCode) {
    final formatted = rate >= 100
        ? NumberFormat('#,##0.##', 'en_US').format(rate)
        : NumberFormat('#,##0.0000', 'en_US').format(rate);
    return '1 $fromCode = $formatted $toCode';
  }
}
