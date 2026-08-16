import 'package:flutter/foundation.dart';
import '../models/subscription.dart';
import '../db/database_helper.dart';

/// Central hub for all subscription data.
/// Every screen that needs subscriptions reads from here instead of
/// talking to the database directly — this keeps data consistent
/// everywhere, and means one refresh updates every screen automatically.
class SubscriptionProvider extends ChangeNotifier {
  List<Subscription> _subscriptions = [];
  bool _isLoading = true;

  List<Subscription> get subscriptions => _subscriptions;
  bool get isLoading => _isLoading;

  double get totalMonthly {
    return _subscriptions.fold(0.0, (sum, s) => sum + s.monthlyCost);
  }

  double get totalYearly => totalMonthly * 12;

  int get activeCount => _subscriptions.length;

  Future<void> loadSubscriptions() async {
    _isLoading = true;
    notifyListeners(); // tells every listening screen "something changed, rebuild"

    _subscriptions = await DatabaseHelper.instance.getAllSubscriptions();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addOrUpdate(Subscription subscription) async {
    await DatabaseHelper.instance.insertSubscription(subscription);
    await loadSubscriptions(); // refresh the shared list so all screens see the change
  }

  Future<void> delete(String id) async {
    await DatabaseHelper.instance.deleteSubscription(id);
    await loadSubscriptions();
  }
}