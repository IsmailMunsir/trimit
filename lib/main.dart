import 'package:flutter/material.dart';
import 'models/subscription.dart';
import 'db/database_helper.dart';
import 'theme/app_theme.dart';
import 'widgets/subscription_card.dart';
import 'widgets/summary_card.dart';
import 'screens/add_subscription_screen.dart';
import 'screens/subscription_detail_screen.dart';

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

  Future<void> _openAddScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddSubscriptionScreen()),
    );
    if (result == true) {
      _loadSubscriptions();
    }
  }

  Future<void> _openDetailScreen(Subscription s) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SubscriptionDetailScreen(subscription: s)),
    );
    if (result == true) {
      _loadSubscriptions();
    }
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined, size: 56, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'No subscriptions yet',
                    style: TextStyle(color: Colors.grey[700], fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap + to add your first one',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                ],
              ),
            )
          else
            ..._subscriptions.map((s) => SubscriptionCard(
                  subscription: s,
                  onTap: () => _openDetailScreen(s),
                )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}