import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rategold/services/board_controller.dart';
import 'package:rategold/services/frankfurter_client.dart';
import 'package:rategold/services/rates_cache_store.dart';
import 'package:rategold/services/rates_repository.dart';
import 'package:rategold/models/rates_snapshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _StubFrankfurter extends FrankfurterClient {
  @override
  Future<RatesSnapshot> fetchLatest({
    required String base,
    required List<String> symbols,
  }) async {
    return RatesSnapshot(
      base: base,
      date: '2026-07-04',
      rates: {'AED': 3.6725, 'PHP': 56.24, 'INR': 83.12, 'IDR': 15840, 'SAR': 3.75},
      fetchedAt: DateTime(2026, 7, 4, 9, 41),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('BoardController loads rates and gold after init', () async {
    final repo = RatesRepository(
      frankfurter: _StubFrankfurter(),
      cacheStore: RatesCacheStore(
        cacheFilePath: () async =>
            '${Directory.systemTemp.path}/rategold_ctrl_${DateTime.now().microsecondsSinceEpoch}.json',
      ),
      minSyncInterval: Duration.zero,
      networkChecker: () async => true,
    );
    final controller = BoardController(repo);
    await controller.initialize();

    expect(controller.isReady, isTrue);
    expect(controller.snapshot.rates.map((r) => r.code), contains('AED'));
    expect(controller.snapshot.goldQuotes, isNotEmpty);
    expect(controller.snapshot.syncStatus.isOnline, isTrue);
  });
}
