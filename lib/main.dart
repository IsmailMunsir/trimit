import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'models/subscription.dart';
import 'db/database_helper.dart';
import 'theme/app_theme.dart';
import 'widgets/subscription_card.dart';
import 'widgets/summary_card.dart';

void main() {
  runApp(const TrimItApp());
}

class TrimItApp extends StatelessWidget {
  const TrimItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrimIt',
      theme: AppTheme.light(),
      home: const TestScreen(),
    );
  }
}

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  List<Subscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    final data = await DatabaseHelper.instance.getAllSubscriptions();
    setState(() {
      _subscriptions = data;
    });
  }

  Future<void> _addSampleSubscription() async {
    final sample = Subscription(
      id: const Uuid().v4(),
      name: 'Netflix',
      cost: 15.99,
      cycle: BillingCycle.monthly,
      category: 'Streaming',
      nextRenewal: DateTime.now().add(const Duration(days: 20)),
    );
    await DatabaseHelper.instance.insertSubscription(sample);
    _loadSubscriptions();
  }

  double get _totalMonthly {
    return _subscriptions.fold(0.0, (sum, s) => sum + s.monthlyCost);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TrimIt')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SummaryCard(totalMonthly: _totalMonthly),
          const SizedBox(height: 20),
          const Text(
            'Your subscriptions',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          const SizedBox(height: 8),
          if (_subscriptions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(child: Text('No subscriptions saved yet')),
            )
          else
            ..._subscriptions.map((s) => SubscriptionCard(subscription: s)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSampleSubscription,
        child: const Icon(Icons.add),
      ),
    );
  }
}