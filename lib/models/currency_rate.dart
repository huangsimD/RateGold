class CurrencyRate {
  const CurrencyRate({
    required this.code,
    required this.name,
    required this.rateDisplay,
    required this.rateValue,
  });

  final String code;
  final String name;
  final String rateDisplay;
  final double rateValue;
}
