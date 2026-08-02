class GoldQuote {
  const GoldQuote({
    required this.marketCode,
    required this.marketLabel,
    required this.unitLabel,
    required this.priceDisplay,
    this.isStale = false,
  });

  final String marketCode;
  final String marketLabel;
  final String unitLabel;
  final String priceDisplay;
  final bool isStale;
}
