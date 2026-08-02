import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rategold/models/rates_snapshot.dart';

class RatesCacheStore {
  RatesCacheStore({Future<String> Function()? cacheFilePath})
      : _cacheFilePath = cacheFilePath ?? _defaultCachePath;

  final Future<String> Function() _cacheFilePath;

  static Future<String> _defaultCachePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/rates_snapshot.json';
  }

  Future<RatesSnapshot?> readCache() async {
    final path = await _cacheFilePath();
    final file = File(path);
    if (!await file.exists()) return null;

    try {
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return RatesSnapshot.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> writeCache(RatesSnapshot snapshot) async {
    final path = await _cacheFilePath();
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(snapshot.toJson()));
  }

  Future<RatesSnapshot> loadBundledSeed() async {
    final raw = await rootBundle.loadString('assets/data/rates_seed.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return RatesSnapshot.fromJson(json);
  }

  Future<GoldSnapshot> loadGoldSeed() async {
    final raw = await rootBundle.loadString('assets/data/gold_seed.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return GoldSnapshot.fromJson(json);
  }

  Future<GoldSnapshot?> readGoldCache() async {
    final path = await _cacheFilePath();
    final goldPath = path.replaceFirst('rates_snapshot.json', 'gold_snapshot.json');
    final file = File(goldPath);
    if (!await file.exists()) return null;
    try {
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return GoldSnapshot.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> writeGoldCache(GoldSnapshot snapshot) async {
    final path = await _cacheFilePath();
    final goldPath = path.replaceFirst('rates_snapshot.json', 'gold_snapshot.json');
    final file = File(goldPath);
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(snapshot.toJson()));
  }
}
