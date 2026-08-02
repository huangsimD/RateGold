import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:rategold/models/rates_snapshot.dart';
import 'package:rategold/models/sync_status.dart';
import 'package:rategold/services/conversion_service.dart';
import 'package:rategold/services/frankfurter_client.dart';
import 'package:rategold/services/rates_cache_store.dart';
import 'package:rategold/services/rates_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeFrankfurter extends FrankfurterClient {
  _FakeFrankfurter({this.onFetch});

  final Future<RatesSnapshot> Function(String base, List<String> symbols)?
      onFetch;

  @override
  Future<RatesSnapshot> fetchLatest({
    required String base,
    required List<String> symbols,
  }) async {
    if (onFetch != null) return onFetch!(base, symbols);
    return RatesSnapshot(
      base: base,
      date: '2026-07-04',
      rates: {'AED': 3.67, 'PHP': 56.0, 'INR': 83.0, 'IDR': 15800},
      fetchedAt: DateTime(2026, 7, 4, 10),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String cachePath;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    cachePath =
        '${Directory.systemTemp.path}/rategold_test_${DateTime.now().microsecondsSinceEpoch}.json';
  });

  tearDown(() {
    final file = File(cachePath);
    if (file.existsSync()) file.deleteSync();
    final goldFile = File(cachePath.replaceFirst('rates_snapshot.json', 'gold_snapshot.json'));
    if (goldFile.existsSync()) goldFile.deleteSync();
  });

  test('initialize loads bundled seed when cache empty', () async {
    final repo = RatesRepository(
      frankfurter: _FakeFrankfurter(),
      cacheStore: RatesCacheStore(cacheFilePath: () async => cachePath),
      networkChecker: () async => true,
    );

    await repo.initialize();
    final snap = repo.snapshot();

    expect(snap.rates, isNotEmpty);
    expect(snap.goldQuotes, isNotEmpty);
    expect(snap.baseCurrency, 'USD');
  });

  test('sync writes cache and returns success', () async {
    final repo = RatesRepository(
      frankfurter: _FakeFrankfurter(),
      cacheStore: RatesCacheStore(cacheFilePath: () async => cachePath),
      minSyncInterval: Duration.zero,
      networkChecker: () async => true,
    );

    await repo.initialize();
    final result = await repo.sync(force: true);

    expect(result, SyncResult.success);
    expect(repo.snapshot().rates.first.code, 'AED');
    expect(File(cachePath).existsSync(), isTrue);
  });

  test('sync failure keeps seed data with syncFailed state', () async {
    final repo = RatesRepository(
      frankfurter: _FakeFrankfurter(
        onFetch: (_, __) async => throw FrankfurterException('network'),
      ),
      cacheStore: RatesCacheStore(cacheFilePath: () async => cachePath),
      minSyncInterval: Duration.zero,
      networkChecker: () async => true,
    );

    await repo.initialize();
    final result = await repo.sync(force: true);

    expect(result, SyncResult.failed);
    expect(repo.snapshot().syncStatus.connection, SyncConnectionState.syncFailed);
    expect(repo.snapshot().rates, isNotEmpty);
  });

  test('sync offline returns offline and keeps cached rates', () async {
    final repo = RatesRepository(
      frankfurter: _FakeFrankfurter(),
      cacheStore: RatesCacheStore(cacheFilePath: () async => cachePath),
      minSyncInterval: Duration.zero,
      networkChecker: () async => true,
    );

    await repo.initialize();
    expect(await repo.sync(force: true), SyncResult.success);
    expect(repo.snapshot().syncStatus.connection, SyncConnectionState.online);

    final offlineRepo = RatesRepository(
      frankfurter: _FakeFrankfurter(
        onFetch: (_, __) async => throw FrankfurterException('should not call'),
      ),
      cacheStore: RatesCacheStore(cacheFilePath: () async => cachePath),
      minSyncInterval: Duration.zero,
      networkChecker: () async => false,
    );
    await offlineRepo.initialize();
    final result = await offlineRepo.sync(force: true);

    expect(result, SyncResult.offline);
    expect(
      offlineRepo.snapshot().syncStatus.connection,
      SyncConnectionState.offline,
    );
    expect(offlineRepo.snapshot().rates, isNotEmpty);
  });

  test('sync respects minSyncInterval throttle', () async {
    final repo = RatesRepository(
      frankfurter: _FakeFrankfurter(),
      cacheStore: RatesCacheStore(cacheFilePath: () async => cachePath),
      minSyncInterval: const Duration(hours: 1),
      networkChecker: () async => true,
    );

    await repo.initialize();
    expect(await repo.sync(force: true), SyncResult.success);
    expect(await repo.sync(force: false), SyncResult.throttled);
  });

  test('sync keeps all five gold markets when API omits SAR', () async {
    final repo = RatesRepository(
      frankfurter: _FakeFrankfurter(
        onFetch: (_, __) async => RatesSnapshot(
          base: 'USD',
          date: '2026-07-04',
          rates: {'AED': 3.67, 'PHP': 56.0, 'INR': 83.0, 'IDR': 15800},
          fetchedAt: DateTime(2026, 7, 4, 12),
        ),
      ),
      cacheStore: RatesCacheStore(cacheFilePath: () async => cachePath),
      minSyncInterval: Duration.zero,
      networkChecker: () async => true,
    );

    await repo.initialize();
    await repo.sync(force: true);

    expect(repo.snapshot().goldQuotes, hasLength(5));
    expect(
      repo.snapshot().goldQuotes.map((q) => q.marketCode).toList(),
      ['INR', 'AED', 'SAR', 'PHP', 'IDR'],
    );
    expect(repo.snapshot().goldQuotes.any((q) => q.isStale), isFalse);
  });

  test('ratesForConversion fills AED and PHP when cache has zero placeholders', () async {
    final repo = RatesRepository(
      frankfurter: _FakeFrankfurter(
        onFetch: (_, __) async => RatesSnapshot(
          base: 'AED',
          date: '2026-07-04',
          rates: {'USD': 0.272, 'PHP': 0},
          fetchedAt: DateTime(2026, 7, 4, 14),
        ),
      ),
      cacheStore: RatesCacheStore(cacheFilePath: () async => cachePath),
      minSyncInterval: Duration.zero,
      networkChecker: () async => true,
    );

    await repo.initialize();
    await repo.sync(force: true);

    final snap = repo.ratesForConversion!;
    expect(snap.rateFor('AED'), 1.0);
    expect(snap.rateFor('PHP'), isNotNull);
    expect(snap.rateFor('PHP'), greaterThan(10));
  });

  test('ratesForConversion triangulates AED when base is EUR and API omits AED', () async {
    final repo = RatesRepository(
      frankfurter: _FakeFrankfurter(
        onFetch: (_, __) async => RatesSnapshot(
          base: 'EUR',
          date: '2026-07-04',
          rates: {'USD': 1.08, 'PHP': 61.0},
          fetchedAt: DateTime(2026, 7, 4, 14),
        ),
      ),
      cacheStore: RatesCacheStore(cacheFilePath: () async => cachePath),
      minSyncInterval: Duration.zero,
      networkChecker: () async => true,
    );

    await repo.initialize();
    await repo.sync(force: true);

    final snap = repo.ratesForConversion!;
    expect(snap.rateFor('AED'), isNotNull);
    expect(snap.rateFor('PHP'), 61.0);
  });

  test('ratesForConversion enables AED to PHP convert when API returns PHP zero', () async {
    final repo = RatesRepository(
      frankfurter: _FakeFrankfurter(
        onFetch: (_, __) async => RatesSnapshot(
          base: 'AED',
          date: '2026-07-04',
          rates: {'USD': 0.272, 'PHP': 0},
          fetchedAt: DateTime(2026, 7, 4, 14),
        ),
      ),
      cacheStore: RatesCacheStore(cacheFilePath: () async => cachePath),
      minSyncInterval: Duration.zero,
      networkChecker: () async => true,
    );

    await repo.initialize();
    await repo.sync(force: true);

    final result = ConversionService.convert(
      snapshot: repo.ratesForConversion!,
      amount: 500,
      fromCode: 'AED',
      toCode: 'PHP',
    );

    expect(result, isNotNull);
    expect(result!.result, closeTo(7740, 5));
  });

  test('sync falls back to USD when preferred base fetch fails', () async {
    SharedPreferences.setMockInitialValues({
      'region_defaults_applied': true,
      'base_currency': 'AED',
      'favorite_codes': ['AED', 'PHP', 'INR'],
    });

    var calls = 0;
    final repo = RatesRepository(
      frankfurter: _FakeFrankfurter(
        onFetch: (base, symbols) async {
          calls++;
          if (base == 'AED') throw FrankfurterException('unsupported base');
          expect(base, 'USD');
          return RatesSnapshot(
            base: 'USD',
            date: '2026-07-04',
            rates: {'AED': 3.6725, 'PHP': 56.85, 'INR': 83.45},
            fetchedAt: DateTime(2026, 7, 4, 15),
          );
        },
      ),
      cacheStore: RatesCacheStore(cacheFilePath: () async => cachePath),
      minSyncInterval: Duration.zero,
      networkChecker: () async => true,
    );

    await repo.initialize();
    final result = await repo.sync(force: true);

    expect(result, SyncResult.success);
    expect(calls, 2);
    expect(repo.ratesSnapshot!.base, 'AED');
    expect(repo.ratesSnapshot!.rateFor('PHP'), isNotNull);
  });

  test('sync failure merges seed into cached snapshot', () async {
    final repo = RatesRepository(
      frankfurter: _FakeFrankfurter(),
      cacheStore: RatesCacheStore(cacheFilePath: () async => cachePath),
      minSyncInterval: Duration.zero,
      networkChecker: () async => true,
    );

    await repo.initialize();
    expect(await repo.sync(force: true), SyncResult.success);

    final failingRepo = RatesRepository(
      frankfurter: _FakeFrankfurter(
        onFetch: (_, __) async => throw FrankfurterException('down'),
      ),
      cacheStore: RatesCacheStore(cacheFilePath: () async => cachePath),
      minSyncInterval: Duration.zero,
      networkChecker: () async => true,
    );
    await failingRepo.initialize();
    expect(await failingRepo.sync(force: true), SyncResult.failed);
    expect(failingRepo.ratesForConversion!.rateFor('PHP'), isNotNull);
  });

  test('first launch applies India region defaults', () async {
    final repo = RatesRepository(
      frankfurter: _FakeFrankfurter(),
      cacheStore: RatesCacheStore(cacheFilePath: () async => cachePath),
      deviceLocale: () => const Locale('en', 'IN'),
    );

    await repo.initialize();

    expect(repo.baseCurrency, 'INR');
    expect(repo.favoriteCodes.first, 'INR');
    expect(repo.regionProfile().convertFrom, 'INR');
  });

  test('region defaults are not overwritten on second initialize', () async {
    SharedPreferences.setMockInitialValues({
      'region_defaults_applied': true,
      'base_currency': 'USD',
      'favorite_codes': ['USD', 'EUR'],
    });

    final repo = RatesRepository(
      frankfurter: _FakeFrankfurter(),
      cacheStore: RatesCacheStore(cacheFilePath: () async => cachePath),
      deviceLocale: () => const Locale('en', 'IN'),
    );

    await repo.initialize();

    expect(repo.baseCurrency, 'USD');
    expect(repo.favoriteCodes, ['USD', 'EUR']);
  });
}
