class AppCurrency {
  final String code; // e.g. "USD"
  final String symbol; // e.g. "$"
  final String name; // e.g. "US Dollar"

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
  AppCurrency(code: 'CNY', symbol: '¥', name: 'Chinese Yuan'),
  AppCurrency(code: 'CHF', symbol: 'Fr', name: 'Swiss Franc'),
  AppCurrency(code: 'NZD', symbol: 'NZ\$', name: 'New Zealand Dollar'),
  AppCurrency(code: 'SGD', symbol: 'S\$', name: 'Singapore Dollar'),
  AppCurrency(code: 'HKD', symbol: 'HK\$', name: 'Hong Kong Dollar'),
  AppCurrency(code: 'AED', symbol: 'د.إ', name: 'UAE Dirham'),
  AppCurrency(code: 'SAR', symbol: '﷼', name: 'Saudi Riyal'),
  AppCurrency(code: 'PKR', symbol: 'Rs', name: 'Pakistani Rupee'),
  AppCurrency(code: 'BDT', symbol: '৳', name: 'Bangladeshi Taka'),
  AppCurrency(code: 'NPR', symbol: 'Rs', name: 'Nepalese Rupee'),
  AppCurrency(code: 'MYR', symbol: 'RM', name: 'Malaysian Ringgit'),
  AppCurrency(code: 'THB', symbol: '฿', name: 'Thai Baht'),
  AppCurrency(code: 'IDR', symbol: 'Rp', name: 'Indonesian Rupiah'),
  AppCurrency(code: 'PHP', symbol: '₱', name: 'Philippine Peso'),
  AppCurrency(code: 'VND', symbol: '₫', name: 'Vietnamese Dong'),
  AppCurrency(code: 'KRW', symbol: '₩', name: 'South Korean Won'),
  AppCurrency(code: 'ZAR', symbol: 'R', name: 'South African Rand'),
  AppCurrency(code: 'NGN', symbol: '₦', name: 'Nigerian Naira'),
  AppCurrency(code: 'EGP', symbol: 'E£', name: 'Egyptian Pound'),
  AppCurrency(code: 'BRL', symbol: 'R\$', name: 'Brazilian Real'),
  AppCurrency(code: 'MXN', symbol: 'MX\$', name: 'Mexican Peso'),
  AppCurrency(code: 'RUB', symbol: '₽', name: 'Russian Ruble'),
  AppCurrency(code: 'TRY', symbol: '₺', name: 'Turkish Lira'),
  AppCurrency(code: 'SEK', symbol: 'kr', name: 'Swedish Krona'),
  AppCurrency(code: 'NOK', symbol: 'kr', name: 'Norwegian Krone'),
  AppCurrency(code: 'DKK', symbol: 'kr', name: 'Danish Krone'),
  AppCurrency(code: 'PLN', symbol: 'zł', name: 'Polish Zloty'),
];

AppCurrency currencyByCode(String code) {
  return kSupportedCurrencies.firstWhere(
    (c) => c.code == code,
    orElse: () => kSupportedCurrencies.first, // fall back to USD if somehow not found
  );
}