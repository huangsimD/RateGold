class RatesSnapshot {
  const RatesSnapshot({
    required this.base,
    required this.date,
    required this.rates,
    required this.fetchedAt,
    this.fromCache = false,
  });

  final String base;
  final String date;
  final Map<String, double> rates;
  final DateTime fetchedAt;
  final bool fromCache;

  factory RatesSnapshot.fromJson(Map<String, dynamic> json) {
    final rawRates = json['rates'] as Map<String, dynamic>;
    return RatesSnapshot(
      base: json['base'] as String,
      date: json['date'] as String,
      rates: {
        for (final entry in rawRates.entries)
          entry.key: (entry.value as num).toDouble(),
      },
      fetchedAt: DateTime.parse(json['fetchedAt'] as String),
      fromCache: json['fromCache'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base': base,
      'date': date,
      'rates': rates,
      'fetchedAt': fetchedAt.toIso8601String(),
      'fromCache': fromCache,
    };
  }

  double? rateFor(String code) {
    if (code == base) return 1.0;
    return rates[code];
  }
}

class GoldSnapshot {
  const GoldSnapshot({
    required this.usdPerOz,
    required this.updatedAt,
    required this.source,
  });

  final double usdPerOz;
  final DateTime updatedAt;
  final String source;

  factory GoldSnapshot.fromJson(Map<String, dynamic> json) {
    return GoldSnapshot(
      usdPerOz: (json['usdPerOz'] as num).toDouble(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      source: json['source'] as String? ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usdPerOz': usdPerOz,
      'updatedAt': updatedAt.toIso8601String(),
      'source': source,
    };
  }

  GoldSnapshot copyWith({
    double? usdPerOz,
    DateTime? updatedAt,
    String? source,
  }) {
    return GoldSnapshot(
      usdPerOz: usdPerOz ?? this.usdPerOz,
      updatedAt: updatedAt ?? this.updatedAt,
      source: source ?? this.source,
    );
  }
}

enum SyncResult { success, throttled, offline, failed }
