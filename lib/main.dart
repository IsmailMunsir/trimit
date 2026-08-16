import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'models/subscription.dart';
import 'db/database_helper.dart';
import 'theme/app_theme.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TrimIt - Database Test')),
      body: _subscriptions.isEmpty
          ? const Center(child: Text('No subscriptions saved yet'))
          : ListView.builder(
              itemCount: _subscriptions.length,
              itemBuilder: (context, index) {
                final s = _subscriptions[index];
                return ListTile(
                  title: Text(s.name),
                  subtitle: Text('\$${s.cost} / ${s.cycle.name}'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSampleSubscription,
        child: const Icon(Icons.add),
      ),
    );
  }
}