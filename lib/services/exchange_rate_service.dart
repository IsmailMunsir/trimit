import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Fetches live USD-based exchange rates from Frankfurter (free, no API
/// key, ECB-backed data). Rates are cached locally so the app still shows
/// a (possibly slightly stale) number if offline, rather than nothing.
class ExchangeRateService {
  static const _ratesKey = 'cached_exchange_rates';
  static const _fetchedAtKey = 'exchange_rates_fetched_at';

  /// Fetches fresh rates from the network and caches them.
  /// Returns a map like {"LKR": 330.16, "EUR": 0.92, ...}, all relative to 1 USD.
  Future<Map<String, double>> fetchLiveRates() async {
    final uri = Uri.parse('https://api.frankfurter.dev/v2/rates?base=USD');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Exchange rate service returned ${response.statusCode}');
    }

    final List<dynamic> data = jsonDecode(response.body);
    final rates = <String, double>{};
    for (final entry in data) {
      final quote = entry['quote'] as String;
      final rate = (entry['rate'] as num).toDouble();
      rates[quote] = rate;
    }
    // USD to USD is always 1, but the API doesn't include it in the list.
    rates['USD'] = 1.0;

    await _cacheRates(rates);
    return rates;
  }

  Future<void> _cacheRates(Map<String, double> rates) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(rates);
    await prefs.setString(_ratesKey, encoded);
    await prefs.setString(_fetchedAtKey, DateTime.now().toIso8601String());
  }

  /// Returns the last successfully cached rates, or null if none exist yet
  /// (e.g. very first launch with no internet available).
  Future<Map<String, double>?> getCachedRates() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_ratesKey);
    if (encoded == null) return null;

    final Map<String, dynamic> decoded = jsonDecode(encoded);
    return decoded.map((key, value) => MapEntry(key, (value as num).toDouble()));
  }

  Future<DateTime?> getLastFetchedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_fetchedAtKey);
    return stored != null ? DateTime.parse(stored) : null;
  }
}