import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rategold/data/currency_catalog.dart';
import 'package:rategold/data/region_currency_profile.dart';
import 'package:rategold/models/currency_rate.dart';
import 'package:rategold/models/gold_quote.dart';
import 'package:rategold/models/rates_snapshot.dart';
import 'package:rategold/models/sync_status.dart';
import 'package:rategold/services/frankfurter_client.dart';
import 'package:rategold/services/fx_fallback.dart';
import 'package:rategold/services/gold_calculator.dart';
import 'package:rategold/services/rates_cache_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BoardSnapshot {
  const BoardSnapshot({
    required this.syncStatus,
    required this.baseCurrency,
    required this.rates,
    required this.goldQuotes,
    required this.isLoading,
    required this.favoriteCodes,
  });

  final SyncStatus syncStatus;
  final String baseCurrency;
  final List<CurrencyRate> rates;
  final List<GoldQuote> goldQuotes;
  final bool isLoading;
  final List<String> favoriteCodes;

  static BoardSnapshot initial() {
    return BoardSnapshot(
      syncStatus: SyncStatus(
        connection: SyncConnectionState.online,
        lastUpdated: DateTime.now(),
      ),
      baseCurrency: CurrencyCatalog.defaultBase,
      rates: const [],
      goldQuotes: const [],
      isLoading: true,
      favoriteCodes: CurrencyCatalog.defaultFavorites,
    );
  }
}

class RatesRepository {
  RatesRepository({
    FrankfurterClient? frankfurter,
    RatesCacheStore? cacheStore,
    Connectivity? connectivity,
    SharedPreferences? prefs,
    Duration minSyncInterval = const Duration(minutes: 15),
    Future<bool> Function()? networkChecker,
    Locale Function()? deviceLocale,
  })  : _frankfurter = frankfurter ?? FrankfurterClient(),
        _cache = cacheStore ?? RatesCacheStore(),
        _connectivity = connectivity ?? Connectivity(),
        _prefs = prefs,
        _minSyncInterval = minSyncInterval,
        _networkChecker = networkChecker,
        _deviceLocale = deviceLocale ?? (() => PlatformDispatcher.instance.locale);

  final FrankfurterClient _frankfurter;
  final RatesCacheStore _cache;
  final Connectivity _connectivity;
  SharedPreferences? _prefs;
  final Duration _minSyncInterval;
  final Future<bool> Function()? _networkChecker;
  final Locale Function() _deviceLocale;

  RatesSnapshot? _ratesSnapshot;
  GoldSnapshot? _goldSnapshot;
  Map<String, double>? _seedRates;
  DateTime? _lastSuccessfulSync;
  SyncConnectionState _connection = SyncConnectionState.online;

  static const _prefsFavorites = 'favorite_codes';
  static const _prefsBase = 'base_currency';
  static const _prefsLastSync = 'last_sync_at';
  static const _prefsRegionDefaultsApplied = 'region_defaults_applied';

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _applyRegionDefaultsIfNeeded();

    _ratesSnapshot = await _cache.readCache();
    _goldSnapshot = await _cache.readGoldCache();

    final seed = await _cache.loadBundledSeed();
    _seedRates = seed.rates;

    if (_ratesSnapshot == null) {
      _ratesSnapshot = seed;
    } else {
      _ratesSnapshot = _withMergedGoldFx(_ratesSnapshot!);
    }
    if (_goldSnapshot == null) {
      _goldSnapshot = await _cache.loadGoldSeed();
    } else {
      _goldSnapshot = await _refreshGoldIfStale(_goldSnapshot!);
    }

    final lastSyncMs = _prefs!.getInt(_prefsLastSync);
    if (lastSyncMs != null) {
      _lastSuccessfulSync = DateTime.fromMillisecondsSinceEpoch(lastSyncMs);
    }
  }

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> _applyRegionDefaultsIfNeeded() async {
    final prefs = await _preferences;
    if (prefs.getBool(_prefsRegionDefaultsApplied) ?? false) return;

    final profile = RegionCurrencyProfile.forLocale(_deviceLocale());
    await prefs.setString(_prefsBase, profile.baseCurrency);
    await prefs.setStringList(_prefsFavorites, profile.favoriteCodes);
    await prefs.setBool(_prefsRegionDefaultsApplied, true);
  }

  /// Exposed for Convert tab defaults (same profile as first launch).
  RegionCurrencyProfile regionProfile() =>
      RegionCurrencyProfile.forLocale(_deviceLocale());

  List<String> get favoriteCodes {
    final stored = _prefs?.getStringList(_prefsFavorites);
    return stored ?? List.of(CurrencyCatalog.defaultFavorites);
  }

  String get baseCurrency =>
      _prefs?.getString(_prefsBase) ?? CurrencyCatalog.defaultBase;

  RatesSnapshot? get ratesSnapshot => _ratesSnapshot;

  /// Snapshot with seed fallbacks for any catalog / favorite pair (e.g. AED→PHP).
  RatesSnapshot? get ratesForConversion {
    final snap = _ratesSnapshot;
    if (snap == null) return null;
    return _withConversionFallbacks(snap);
  }

  GoldSnapshot? get goldSnapshot => _goldSnapshot;

  DateTime? get lastSuccessfulSync => _lastSuccessfulSync;

  Future<void> setBaseCurrency(String code) async {
    final prefs = await _preferences;
    await prefs.setString(_prefsBase, code);
  }

  Future<void> setFavoriteCodes(List<String> codes) async {
    if (codes.length > CurrencyCatalog.maxFavorites) {
      throw ArgumentError('Maximum ${CurrencyCatalog.maxFavorites} favorites');
    }
    if (codes.isEmpty) {
      throw ArgumentError('At least one favorite required');
    }
    final prefs = await _preferences;
    await prefs.setStringList(_prefsFavorites, codes);
  }

  BoardSnapshot snapshot({bool isLoading = false}) {
    final rates = _ratesSnapshot;
    final gold = _goldSnapshot;
    final lastUpdated = _lastSuccessfulSync ??
        rates?.fetchedAt ??
        DateTime.now();

    return BoardSnapshot(
      syncStatus: SyncStatus(
        connection: _connection,
        lastUpdated: lastUpdated,
        timezoneLabel: 'UTC',
      ),
      baseCurrency: baseCurrency,
      rates: rates == null
          ? const []
          : GoldCalculator.buildRateList(
              snapshot: rates,
              favoriteCodes: favoriteCodes,
            ),
      goldQuotes: rates == null || gold == null
          ? const []
          : GoldCalculator.buildQuotes(
              gold: gold,
              rates: rates,
              markets: CurrencyCatalog.goldMarkets,
            ),
      isLoading: isLoading,
      favoriteCodes: favoriteCodes,
    );
  }

  Future<bool> _hasNetwork() async {
    final checker = _networkChecker;
    if (checker != null) return checker();
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Future<SyncResult> sync({bool force = false}) async {
    if (!force &&
        _lastSuccessfulSync != null &&
        DateTime.now().difference(_lastSuccessfulSync!) < _minSyncInterval) {
      return SyncResult.throttled;
    }

    final online = await _hasNetwork();
    if (!online) {
      _connection = SyncConnectionState.offline;
      if (_ratesSnapshot != null) {
        return SyncResult.offline;
      }
      return SyncResult.failed;
    }

    try {
      final symbols = {
        ...favoriteCodes,
        ...CurrencyCatalog.goldMarkets,
        ...CurrencyCatalog.allCodes,
      }.toList();

      final fetched = await _fetchRatesWithFallback(symbols);
      final seed = _seedRates ?? {};

      _ratesSnapshot = RatesSnapshot(
        base: fetched.base,
        date: fetched.date,
        rates: _mergeRatesWithSeed(
          base: fetched.base,
          prior: _ratesSnapshot?.rates ?? seed,
          fetched: fetched.rates,
          seed: seed,
          requiredCodes: _requiredRateCodes,
        ),
        fetchedAt: fetched.fetchedAt,
      );
      await _cache.writeCache(_ratesSnapshot!);

      final bundledGold = await _cache.loadGoldSeed();
      _goldSnapshot = (_goldSnapshot ?? bundledGold).copyWith(
        usdPerOz: bundledGold.usdPerOz,
        updatedAt: DateTime.now().toUtc(),
        source: 'bundled spot · FX synced',
      );
      await _cache.writeGoldCache(_goldSnapshot!);

      _lastSuccessfulSync = DateTime.now();
      _connection = SyncConnectionState.online;

      final prefs = await _preferences;
      await prefs.setInt(
        _prefsLastSync,
        _lastSuccessfulSync!.millisecondsSinceEpoch,
      );

      return SyncResult.success;
    } catch (_) {
      if (_ratesSnapshot != null) {
        _ratesSnapshot = _withConversionFallbacks(_ratesSnapshot!);
        _connection = SyncConnectionState.syncFailed;
        return SyncResult.failed;
      }
      _ratesSnapshot = await _cache.loadBundledSeed();
      _seedRates = _ratesSnapshot!.rates;
      _ratesSnapshot = _withConversionFallbacks(_ratesSnapshot!);
      _goldSnapshot = await _cache.loadGoldSeed();
      _connection = SyncConnectionState.offline;
      return SyncResult.offline;
    }
  }

  Future<RatesSnapshot> _fetchRatesWithFallback(List<String> symbols) async {
    final preferredBase = baseCurrency;
    final seed = _seedRates ?? {};

    try {
      final primary = await _frankfurter.fetchLatest(
        base: preferredBase,
        symbols: symbols,
      );
      if (primary.rates.isNotEmpty) return primary;
    } catch (_) {
      // Fall through to USD fetch.
    }

    final usdSymbols = {
      ...symbols,
      if (preferredBase != 'USD') preferredBase,
    }.toList();

    final usdFetch = await _frankfurter.fetchLatest(
      base: 'USD',
      symbols: usdSymbols,
    );

    if (usdFetch.rates.isEmpty) {
      throw FrankfurterException('Empty rates from Frankfurter');
    }

    if (preferredBase == 'USD') return usdFetch;

    return rebaseUsdSnapshot(
      usdSnapshot: usdFetch,
      targetBase: preferredBase,
      seedUsdRates: seed,
    );
  }

  Future<GoldSnapshot> _refreshGoldIfStale(GoldSnapshot cached) async {
    const maxAge = Duration(days: 7);
    if (DateTime.now().difference(cached.updatedAt) < maxAge &&
        cached.usdPerOz > 0) {
      return cached;
    }
    final bundled = await _cache.loadGoldSeed();
    await _cache.writeGoldCache(bundled);
    return bundled;
  }

  Iterable<String> get _requiredRateCodes => {
        ...CurrencyCatalog.allCodes,
        ...CurrencyCatalog.goldMarkets,
        ...favoriteCodes,
      };

  RatesSnapshot _withMergedGoldFx(RatesSnapshot snapshot) {
    final seed = _seedRates;
    if (seed == null) return snapshot;
    return RatesSnapshot(
      base: snapshot.base,
      date: snapshot.date,
      rates: _mergeRatesWithSeed(
        base: snapshot.base,
        prior: snapshot.rates,
        fetched: const {},
        seed: seed,
        requiredCodes: _requiredRateCodes,
      ),
      fetchedAt: snapshot.fetchedAt,
      fromCache: snapshot.fromCache,
    );
  }

  RatesSnapshot _withConversionFallbacks(RatesSnapshot snapshot) {
    final seed = _seedRates;
    if (seed == null) return snapshot;
    return RatesSnapshot(
      base: snapshot.base,
      date: snapshot.date,
      rates: _mergeRatesWithSeed(
        base: snapshot.base,
        prior: snapshot.rates,
        fetched: const {},
        seed: seed,
        requiredCodes: _requiredRateCodes,
      ),
      fetchedAt: snapshot.fetchedAt,
      fromCache: snapshot.fromCache,
    );
  }

  static Map<String, double> _mergeRatesWithSeed({
    required String base,
    required Map<String, double> prior,
    required Map<String, double> fetched,
    required Map<String, double> seed,
    required Iterable<String> requiredCodes,
  }) {
    final merged = {...prior, ...fetched};

    for (final code in requiredCodes) {
      if (code == base) continue;

      final existing = merged[code];
      if (existing != null && existing > 0) continue;

      final fallback = _rateFromUsdSeed(seed, base, code) ??
          (prior[code] != null && prior[code]! > 0 ? prior[code] : null);
      if (fallback != null && fallback > 0) {
        merged[code] = fallback;
      }
    }

    merged.removeWhere((key, value) => value <= 0);
    return merged;
  }

  /// [seed] holds USD-based rates; returns [code] per 1 [base].
  static double? _rateFromUsdSeed(
    Map<String, double> seed,
    String base,
    String code,
  ) {
    if (base == 'USD') return seed[code];
    final codeUsd = seed[code];
    final baseUsd = seed[base];
    if (codeUsd == null || baseUsd == null || baseUsd <= 0) return null;
    return codeUsd / baseUsd;
  }
}
