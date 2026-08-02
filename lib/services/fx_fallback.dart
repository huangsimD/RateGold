import 'package:rategold/models/rates_snapshot.dart';
import 'package:rategold/services/frankfurter_client.dart';

/// Re-base a USD-quoted Frankfurter snapshot to [targetBase].
RatesSnapshot rebaseUsdSnapshot({
  required RatesSnapshot usdSnapshot,
  required String targetBase,
  required Map<String, double> seedUsdRates,
}) {
  if (targetBase == 'USD') return usdSnapshot;

  final usdRates = usdSnapshot.rates;
  final basePerUsd = usdRates[targetBase] ?? seedUsdRates[targetBase];
  if (basePerUsd == null || basePerUsd <= 0) {
    throw FrankfurterException('Cannot rebase USD snapshot to $targetBase');
  }

  final rebased = <String, double>{};
  for (final code in {...usdRates.keys, ...seedUsdRates.keys}) {
    if (code == targetBase) continue;
    final codePerUsd = usdRates[code] ?? seedUsdRates[code];
    if (codePerUsd == null || codePerUsd <= 0) continue;
    rebased[code] = codePerUsd / basePerUsd;
  }
  rebased['USD'] = 1 / basePerUsd;

  return RatesSnapshot(
    base: targetBase,
    date: usdSnapshot.date,
    rates: rebased,
    fetchedAt: usdSnapshot.fetchedAt,
  );
}
