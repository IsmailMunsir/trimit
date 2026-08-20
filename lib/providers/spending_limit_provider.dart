import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpendingLimitProvider extends ChangeNotifier {
  static const _prefsKey = 'spending_limit_amount';
  static const _lastWarnedKey = 'spending_limit_last_warned_total';

  double? _limit; // null = no limit set

  double? get limit => _limit;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble(_prefsKey);
    _limit = saved;
    notifyListeners();
  }

  Future<void> setLimit(double? limit) async {
    _limit = limit;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (limit == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setDouble(_prefsKey, limit);
    }
  }

  /// Returns true if a warning should be shown right now: a limit is set,
  /// the current total exceeds it, AND we haven't already warned for this
  /// exact total (so it doesn't re-notify every single app open).
  Future<bool> shouldWarn(double currentTotalUsd) async {
    if (_limit == null) return false;
    if (currentTotalUsd <= _limit!) return false;

    final prefs = await SharedPreferences.getInstance();
    final lastWarned = prefs.getDouble(_lastWarnedKey);
    if (lastWarned == currentTotalUsd) return false;

    await prefs.setDouble(_lastWarnedKey, currentTotalUsd);
    return true;
  }
}