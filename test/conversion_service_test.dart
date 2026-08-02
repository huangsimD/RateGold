import 'package:flutter_test/flutter_test.dart';
import 'package:rategold/models/rates_snapshot.dart';
import 'package:rategold/services/conversion_service.dart';

void main() {
  final snapshot = RatesSnapshot(
    base: 'USD',
    date: '2026-07-04',
    rates: {'AED': 3.6725, 'PHP': 56.24, 'INR': 83.12},
    fetchedAt: DateTime(2026, 7, 4, 9, 41),
  );

  test('convert AED to PHP via USD base', () {
    final result = ConversionService.convert(
      snapshot: snapshot,
      amount: 500,
      fromCode: 'AED',
      toCode: 'PHP',
    );

    expect(result, isNotNull);
    expect(result!.result, closeTo(7656.57, 1));
    expect(result.crossRate, closeTo(15.315, 0.01));
  });

  test('convert USD to INR uses direct rate', () {
    final result = ConversionService.convert(
      snapshot: snapshot,
      amount: 100,
      fromCode: 'USD',
      toCode: 'INR',
    );

    expect(result, isNotNull);
    expect(result!.result, closeTo(8312, 0.01));
    expect(result.crossRate, 83.12);
  });

  test('formatAmount rounds IDR without decimals', () {
    expect(
      ConversionService.formatAmount(15840.4, 'IDR'),
      '15,840',
    );
  });
}
