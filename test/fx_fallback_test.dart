import 'package:flutter_test/flutter_test.dart';
import 'package:rategold/models/rates_snapshot.dart';
import 'package:rategold/services/frankfurter_client.dart';
import 'package:rategold/services/fx_fallback.dart';

void main() {
  const seed = {
    'AED': 3.6725,
    'PHP': 56.85,
    'INR': 83.45,
    'USD': 1.0,
  };

  final usdSnapshot = RatesSnapshot(
    base: 'USD',
    date: '2026-07-04',
    rates: {'AED': 3.6725, 'PHP': 56.85, 'INR': 83.45, 'EUR': 0.918},
    fetchedAt: DateTime(2026, 7, 4, 10),
  );

  test('rebaseUsdSnapshot converts USD quotes to AED base', () {
    final rebased = rebaseUsdSnapshot(
      usdSnapshot: usdSnapshot,
      targetBase: 'AED',
      seedUsdRates: seed,
    );

    expect(rebased.base, 'AED');
    expect(rebased.rateFor('AED'), 1.0);
    expect(rebased.rateFor('PHP'), closeTo(15.48, 0.01));
  });

  test('rebaseUsdSnapshot returns same snapshot when target is USD', () {
    final rebased = rebaseUsdSnapshot(
      usdSnapshot: usdSnapshot,
      targetBase: 'USD',
      seedUsdRates: seed,
    );
    expect(rebased.base, 'USD');
    expect(rebased.rates['PHP'], 56.85);
  });

  test('rebaseUsdSnapshot throws when base missing from USD and seed', () {
    expect(
      () => rebaseUsdSnapshot(
        usdSnapshot: RatesSnapshot(
          base: 'USD',
          date: '2026-07-04',
          rates: {'PHP': 56.85},
          fetchedAt: DateTime(2026, 7, 4),
        ),
        targetBase: 'AED',
        seedUsdRates: const {},
      ),
      throwsA(isA<FrankfurterException>()),
    );
  });
}
