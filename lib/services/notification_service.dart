import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../models/subscription.dart';

/// Wraps flutter_local_notifications so all scheduling logic lives in one
/// place. Handles three alert types: renewal reminders, trial-expiry
/// alerts, and spending-limit warnings. Runs fully on-device — no push
/// server needed.
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(initSettings);

    // Android 13+ requires runtime permission for notifications.
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Exact alarms need a separate runtime permission on Android 12+.
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    _initialized = true;
  }

  // Stable, distinct notification IDs derived from the subscription id,
  // offset per alert type so the three kinds never collide with each other.
  int _renewalId(String subscriptionId) => (subscriptionId.hashCode & 0x0FFFFFFF);
  int _trialId(String subscriptionId) => (subscriptionId.hashCode & 0x0FFFFFFF) + 1;

  Future<void> scheduleRenewalReminder(Subscription s) async {
    await cancelRenewalReminder(s.id);
    if (!s.reminderEnabled) return;

    final reminderDate = DateTime(
      s.nextRenewal.year,
      s.nextRenewal.month,
      s.nextRenewal.day - s.reminderDaysBefore,
      10, // 10:00 AM
    );
    if (reminderDate.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      'renewal_channel',
      'Renewal Reminders',
      channelDescription: 'Alerts before a subscription renews and charges you',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _plugin.zonedSchedule(
      _renewalId(s.id),
      '${s.name} renews soon',
      'Renews on ${s.nextRenewal.month}/${s.nextRenewal.day} for ${s.cost.toStringAsFixed(2)}',
      tz.TZDateTime.from(reminderDate, tz.local),
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleTrialExpiryAlert(Subscription s) async {
    await cancelTrialAlert(s.id);
    if (!s.isTrial || s.trialEndDate == null) return;

    // Trial alerts fire 2 days before the trial ends — a fixed lead time,
    // separate from the user-configurable renewal reminder days.
    final alertDate = DateTime(
      s.trialEndDate!.year,
      s.trialEndDate!.month,
      s.trialEndDate!.day - 2,
      10,
    );
    if (alertDate.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      'trial_channel',
      'Trial Expiry Alerts',
      channelDescription: 'Alerts before a free trial ends',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _plugin.zonedSchedule(
      _trialId(s.id),
      '${s.name} trial ending soon',
      'Your free trial ends ${s.trialEndDate!.month}/${s.trialEndDate!.day} — cancel now if you don\'t want to be charged',
      tz.TZDateTime.from(alertDate, tz.local),
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelRenewalReminder(String subscriptionId) async {
    await _plugin.cancel(_renewalId(subscriptionId));
  }

  Future<void> cancelTrialAlert(String subscriptionId) async {
    await _plugin.cancel(_trialId(subscriptionId));
  }

  Future<void> cancelAllForSubscription(String subscriptionId) async {
    await cancelRenewalReminder(subscriptionId);
    await cancelTrialAlert(subscriptionId);
  }

  /// TEMPORARY — for testing only, fires 10 seconds from now.
  /// We'll remove this once we've confirmed notifications work end-to-end.
  Future<void> showTestNotificationSoon() async {
    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Used only to verify notifications work correctly',
      importance: Importance.high,
      priority: Priority.high,
    );

    final fireTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));

    await _plugin.zonedSchedule(
      888888888,
      'Test notification',
      'If you see this, notifications are working correctly!',
      fireTime,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Shown immediately (not scheduled) — used for the spending-limit
  /// warning, which is triggered by app logic rather than a fixed date.
  Future<void> showSpendingLimitWarning(double currentTotal, double limit, String symbol) async {
    const androidDetails = AndroidNotificationDetails(
      'spending_limit_channel',
      'Spending Limit Warnings',
      channelDescription: 'Alerts when your total monthly spend crosses your set limit',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _plugin.show(
      999999999, // fixed id — only one spending-limit warning needs to exist at a time
      'You\'ve crossed your spending limit',
      'Your subscriptions now total $symbol${currentTotal.toStringAsFixed(2)}/mo, over your $symbol${limit.toStringAsFixed(2)} limit',
      const NotificationDetails(android: androidDetails),
    );
  }
}