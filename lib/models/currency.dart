class AppCurrency {
  final String code; // e.g. 'USD'
  final String symbol; // e.g. '$'
  final String name; // e.g. 'US Dollar'

  const AppCurrency({required this.code, required this.symbol, required this.name});
}

const List<AppCurrency> kSupportedCurrencies = [
  AppCurrency(code: 'USD', symbol: '\$', name: 'US Dollar'),
  AppCurrency(code: 'LKR', symbol: 'Rs', name: 'Sri Lankan Rupee'),
  AppCurrency(code: 'GBP', symbol: '£', name: 'British Pound'),
  AppCurrency(code: 'EUR', symbol: '€', name: 'Euro'),
  AppCurrency(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
  AppCurrency(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar'),
  AppCurrency(code: 'CAD', symbol: 'C\$', name: 'Canadian Dollar'),
  AppCurrency(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
];

AppCurrency currencyByCode(String code) {
  return kSupportedCurrencies.firstWhere(
    (c) => c.code == code,
    orElse: () => kSupportedCurrencies.first,
  );
}