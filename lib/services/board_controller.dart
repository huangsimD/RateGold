import 'package:flutter/foundation.dart';
import 'package:rategold/data/region_currency_profile.dart';
import 'package:rategold/models/rates_snapshot.dart';
import 'package:rategold/models/sync_status.dart';
import 'package:rategold/services/rates_repository.dart';

class BoardController extends ChangeNotifier {
  BoardController(this._repository);

  final RatesRepository _repository;

  BoardSnapshot _snapshot = BoardSnapshot.initial();
  bool _initialized = false;
  bool _syncFailureDismissed = false;

  BoardSnapshot get snapshot => _snapshot;
  bool get isReady => _initialized;
  bool get showSyncFailureBanner =>
      _snapshot.syncStatus.connection == SyncConnectionState.syncFailed &&
      !_syncFailureDismissed;
  RatesSnapshot? get ratesSnapshot => _repository.ratesSnapshot;
  RatesSnapshot? get ratesForConversion => _repository.ratesForConversion;
  RegionCurrencyProfile get regionProfile => _repository.regionProfile();
  GoldSnapshot? get goldSnapshot => _repository.goldSnapshot;
  DateTime? get lastSuccessfulSync => _repository.lastSuccessfulSync;

  Future<void> initialize() async {
    await _repository.initialize();
    _snapshot = _repository.snapshot(isLoading: true);
    notifyListeners();

    await _repository.sync();
    _refreshSnapshot();
    _initialized = true;
    notifyListeners();
  }

  Future<SyncResult> refresh({bool force = true}) async {
    _snapshot = _repository.snapshot(isLoading: true);
    notifyListeners();

    final result = await _repository.sync(force: force);
    if (result == SyncResult.failed) {
      _syncFailureDismissed = false;
    }
    _refreshSnapshot();
    notifyListeners();
    return result;
  }

  void dismissSyncFailureBanner() {
    if (!_syncFailureDismissed) {
      _syncFailureDismissed = true;
      notifyListeners();
    }
  }

  Future<void> updateBaseCurrency(String code) async {
    if (code == _repository.baseCurrency) return;
    await _repository.setBaseCurrency(code);
    _snapshot = _repository.snapshot(isLoading: true);
    notifyListeners();
    await _repository.sync(force: true);
    _refreshSnapshot();
    notifyListeners();
  }

  Future<void> updateFavoriteCodes(List<String> codes) async {
    await _repository.setFavoriteCodes(codes);
    _snapshot = _repository.snapshot(isLoading: true);
    notifyListeners();
    await _repository.sync(force: true);
    _refreshSnapshot();
    notifyListeners();
  }

  void _refreshSnapshot() {
    _snapshot = _repository.snapshot(isLoading: false);
  }
}
