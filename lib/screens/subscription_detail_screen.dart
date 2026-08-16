import 'package:flutter/material.dart';
import '../models/subscription.dart';
import '../db/database_helper.dart';
import 'add_subscription_screen.dart';

class SubscriptionDetailScreen extends StatelessWidget {
  final Subscription subscription;

  const SubscriptionDetailScreen({super.key, required this.subscription});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete subscription?'),
        content: Text('This will remove "${subscription.name}" permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.deleteSubscription(subscription.id);
      if (context.mounted) {
        Navigator.pop(context, true); // tell home screen to refresh
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subscription.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddSubscriptionScreen(existing: subscription),
                ),
              );
              if (result == true && context.mounted) {
                Navigator.pop(context, true); // also refresh the home screen behind this one
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\$${subscription.cost.toStringAsFixed(2)} / ${subscription.cycle.name}',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            _infoRow('Category', subscription.category),
            _infoRow(
              'Next renewal',
              '${subscription.nextRenewal.year}-${subscription.nextRenewal.month.toString().padLeft(2, '0')}-${subscription.nextRenewal.day.toString().padLeft(2, '0')}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(color: Colors.grey[600]))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}