import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/currency.dart';
import '../services/exchange_rate_service.dart';

class CurrencyProvider extends ChangeNotifier {
  static const _prefsKey = 'selected_currency_code';

  final ExchangeRateService _rateService = ExchangeRateService();

  AppCurrency _currency = kSupportedCurrencies.first; // defaults to USD
  Map<String, double> _rates = {'USD': 1.0};
  DateTime? _ratesFetchedAt;
  bool _isFetchingRates = false;
  String? _rateError;

  AppCurrency get currency => _currency;
  DateTime? get ratesFetchedAt => _ratesFetchedAt;
  bool get isFetchingRates => _isFetchingRates;
  String? get rateError => _rateError;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_prefsKey);
    if (savedCode != null) {
      _currency = currencyByCode(savedCode);
    }

    final cached = await _rateService.getCachedRates();
    if (cached != null) {
      _rates = cached;
      _ratesFetchedAt = await _rateService.getLastFetchedAt();
    }
    notifyListeners();

    await refreshRates();
  }

  Future<void> refreshRates() async {
    _isFetchingRates = true;
    _rateError = null;
    notifyListeners();

    try {
      _rates = await _rateService.fetchLiveRates();
      _ratesFetchedAt = DateTime.now();
    } catch (e) {
      _rateError = 'Could not fetch live rates. Showing last known rates.';
    }

    _isFetchingRates = false;
    notifyListeners();
  }

  Future<void> setCurrency(AppCurrency currency) async {
    _currency = currency;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, currency.code);
  }

  double convert(double amountInUsd) {
    final rate = _rates[_currency.code] ?? 1.0;
    return amountInUsd * rate;
  }
}