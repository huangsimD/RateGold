import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Anonymous ops ingest. No-op unless compiled with non-empty [OPS_BASE_URL].
///
/// Production release builds must NOT pass OPS_BASE_URL.
class OpsAnalytics {
  OpsAnalytics({http.Client? client}) : _client = client ?? http.Client();

  static const baseUrl = String.fromEnvironment('OPS_BASE_URL');
  static const ingestToken = String.fromEnvironment('OPS_INGEST_TOKEN');
  static const appVersionOverride = String.fromEnvironment('OPS_APP_VERSION');

  static const _installIdKey = 'ops_install_id';
  static const _firstOpenKey = 'ops_first_open_sent';

  final http.Client _client;
  String? _installId;
  String? _appVersion;
  String? _locale;
  bool _ready = false;
  String? _lastScreen;

  static bool get enabled => baseUrl.trim().isNotEmpty;

  Future<void> initialize({String? locale, String? appVersion}) async {
    _locale = locale;
    _appVersion = appVersionOverride.isNotEmpty
        ? appVersionOverride
        : appVersion;
    if (!enabled) {
      _ready = true;
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_installIdKey);
    if (id == null || id.isEmpty) {
      id = _newInstallId();
      await prefs.setString(_installIdKey, id);
    }
    _installId = id;
    _ready = true;

    final firstSent = prefs.getBool(_firstOpenKey) ?? false;
    if (!firstSent) {
      await track('first_open');
      await prefs.setBool(_firstOpenKey, true);
    }
    await track('app_open');
  }

  void setLocale(String? locale) {
    _locale = locale;
  }

  Future<void> screenView(String screen) async {
    if (!enabled || !_ready) return;
    if (_lastScreen == screen) return;
    _lastScreen = screen;
    await track('screen_view', screen: screen);
  }

  Future<void> track(String event, {String? screen}) async {
    if (!enabled || !_ready || _installId == null) return;
    final uri = Uri.parse(
      '${baseUrl.replaceAll(RegExp(r'/+$'), '')}/v1/events',
    );
    final body = <String, dynamic>{
      'install_id': _installId,
      'event': event,
      'ts': DateTime.now().toUtc().toIso8601String(),
      if (screen != null) 'screen': screen,
      if (_appVersion != null && _appVersion!.isNotEmpty)
        'app_version': _appVersion,
      if (_locale != null) 'locale': _locale,
    };
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (ingestToken.isNotEmpty) 'X-Ops-Token': ingestToken,
    };
    try {
      await _client
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 8));
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('OpsAnalytics track failed: $e\n$st');
      }
    }
  }

  String _newInstallId() {
    final r = Random.secure();
    final bytes = List<int>.generate(16, (_) => r.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    String h(int i) => bytes[i].toRadixString(16).padLeft(2, '0');
    return '${h(0)}${h(1)}${h(2)}${h(3)}-'
        '${h(4)}${h(5)}-'
        '${h(6)}${h(7)}-'
        '${h(8)}${h(9)}-'
        '${h(10)}${h(11)}${h(12)}${h(13)}${h(14)}${h(15)}';
  }
}
