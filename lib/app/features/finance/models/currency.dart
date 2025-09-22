enum Currency {
  fcfa('FCFA', 'F CFA', 'XOF'),
  usd('USD', '\$', 'USD'),
  eur('EUR', '€', 'EUR');

  const Currency(this.code, this.symbol, this.isoCode);

  final String code;
  final String symbol;
  final String isoCode;

  static Currency get defaultCurrency => Currency.fcfa;

  static Currency fromString(String value) {
    return Currency.values.firstWhere(
      (currency) => currency.code == value || currency.isoCode == value,
      orElse: () => Currency.fcfa,
    );
  }

  String formatAmount(double amount) {
    switch (this) {
      case Currency.fcfa:
        return '${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )} $code';
      case Currency.usd:
      case Currency.eur:
        return '$symbol${amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'symbol': symbol,
      'isoCode': isoCode,
    };
  }

  static Currency fromMap(Map<String, dynamic> map) {
    return fromString(map['code'] ?? map['isoCode'] ?? 'FCFA');
  }

  String get name {
    switch (this) {
      case Currency.fcfa:
        return 'Franc CFA';
      case Currency.usd:
        return 'Dollar Américain';
      case Currency.eur:
        return 'Euro';
    }
  }
}