import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/currency.dart';

class CurrencyProvider extends ChangeNotifier {
  static const _prefsKey = 'selected_currency_code';

  AppCurrency _currency = kSupportedCurrencies.first; // defaults to USD

  AppCurrency get currency => _currency;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_prefsKey);
    if (savedCode != null) {
      _currency = currencyByCode(savedCode);
      notifyListeners();
    }
  }

  Future<void> setCurrency(AppCurrency currency) async {
    _currency = currency;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, currency.code);
  }
}