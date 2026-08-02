import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rategold/models/rates_snapshot.dart';

class FrankfurterClient {
  FrankfurterClient({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? 'https://api.frankfurter.app';

  final http.Client _client;
  final String _baseUrl;

  Future<RatesSnapshot> fetchLatest({
    required String base,
    required List<String> symbols,
  }) async {
    final filtered = symbols.where((c) => c != base).toList();
    if (filtered.isEmpty) {
      return RatesSnapshot(
        base: base,
        date: _todayIso(),
        rates: const {},
        fetchedAt: DateTime.now().toUtc(),
      );
    }

    final uri = Uri.parse('$_baseUrl/latest').replace(
      queryParameters: {
        'from': base,
        'to': filtered.join(','),
      },
    );

    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw FrankfurterException('HTTP ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final ratesRaw = json['rates'] as Map<String, dynamic>? ?? {};
    final rates = {
      for (final e in ratesRaw.entries) e.key: (e.value as num).toDouble(),
    };

    return RatesSnapshot(
      base: json['base'] as String? ?? base,
      date: json['date'] as String? ?? _todayIso(),
      rates: rates,
      fetchedAt: DateTime.now().toUtc(),
    );
  }

  static String _todayIso() {
    final now = DateTime.now().toUtc();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

class FrankfurterException implements Exception {
  FrankfurterException(this.message);
  final String message;

  @override
  String toString() => 'FrankfurterException: $message';
}
