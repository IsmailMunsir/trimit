import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/subscription.dart';
import '../models/payment_record.dart';
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
    notifyListeners();

    _subscriptions = await DatabaseHelper.instance.getAllSubscriptions();

    // Automatically process any subscriptions whose renewal date has
    // already passed: log a payment record for that date, then advance
    // the renewal date forward by one billing cycle. Runs every time
    // data loads, so it stays current without any manual step.
    await _processDuePayments();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _processDuePayments() async {
    final now = DateTime.now();
    bool anyChanged = false;

    for (final s in _subscriptions) {
      // Only auto-process subscriptions that are actually still running —
      // paused, cancelled, or archived items don't accrue new payments.
      final isRunning = (s.status == SubscriptionStatus.active || s.status == SubscriptionStatus.trial) &&
          !s.isArchived;
      if (!isRunning) continue;

      var current = s;
      // A while loop, not just "if", so a subscription that was untouched
      // for multiple billing cycles (e.g. app unused for 3 months) catches
      // up correctly with one payment record per missed cycle.
      while (current.nextRenewal.isBefore(now)) {
        final record = PaymentRecord(
          id: const Uuid().v4(),
          subscriptionId: current.id,
          subscriptionName: current.name,
          amount: current.cost,
          paidOn: current.nextRenewal,
        );
        await DatabaseHelper.instance.insertPaymentRecord(record);

        final advanced = _advanceRenewalDate(current.nextRenewal, current.cycle);
        current = current.copyWith(nextRenewal: advanced);
        anyChanged = true;
      }

      if (current.nextRenewal != s.nextRenewal) {
        await DatabaseHelper.instance.insertSubscription(current);
      }
    }

    if (anyChanged) {
      _subscriptions = await DatabaseHelper.instance.getAllSubscriptions();
    }
  }

  DateTime _advanceRenewalDate(DateTime date, BillingCycle cycle) {
    switch (cycle) {
      case BillingCycle.weekly:
        return date.add(const Duration(days: 7));
      case BillingCycle.monthly:
        // Adding a month by shifting the month number handles varying
        // month lengths more sensibly than a fixed 30-day jump.
        final nextMonth = date.month == 12 ? 1 : date.month + 1;
        final nextYear = date.month == 12 ? date.year + 1 : date.year;
        return DateTime(nextYear, nextMonth, date.day);
      case BillingCycle.yearly:
        return DateTime(date.year + 1, date.month, date.day);
    }
  }

  Future<List<PaymentRecord>> getPaymentHistory(String subscriptionId) {
    return DatabaseHelper.instance.getPaymentHistoryFor(subscriptionId);
  }

  Future<void> addOrUpdate(Subscription subscription) async {
    await DatabaseHelper.instance.insertSubscription(subscription);
    await loadSubscriptions();
  }

  Future<void> delete(String id) async {
    await DatabaseHelper.instance.deleteSubscription(id);
    await loadSubscriptions();
  }
}