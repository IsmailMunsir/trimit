import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import 'add_subscription_screen.dart';

class SubscriptionDetailScreen extends StatelessWidget {
  final Subscription subscription;

  const SubscriptionDetailScreen({super.key, required this.subscription});

  Future<void> _confirmDelete(BuildContext context) async {
    final provider = context.read<SubscriptionProvider>();

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
      await provider.delete(subscription.id);
      if (context.mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _toggleArchive(BuildContext context) async {
    final provider = context.read<SubscriptionProvider>();
    final updated = subscription.copyWith(isArchived: !subscription.isArchived);
    await provider.addOrUpdate(updated);
    if (context.mounted) {
      Navigator.pop(context, true);
    }
  }

  String _statusLabel(SubscriptionStatus s) {
    switch (s) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.trial:
        return 'Trial';
      case SubscriptionStatus.paused:
        return 'Paused';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subscription.name),
        actions: [
          if (!subscription.isArchived)
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
                  Navigator.pop(context, true);
                }
              },
            ),
          IconButton(
            icon: Icon(subscription.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined),
            tooltip: subscription.isArchived ? 'Unarchive' : 'Archive',
            onPressed: () => _toggleArchive(context),
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
            Row(
              children: [
                Text(
                  '\$${subscription.cost.toStringAsFixed(2)} / ${subscription.cycle.name}',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                ),
                if (subscription.isFavorite) ...[
                  const SizedBox(width: 10),
                  const Icon(Icons.star, color: Colors.amber, size: 22),
                ],
              ],
            ),
            const SizedBox(height: 20),
            _infoRow('Status', _statusLabel(subscription.status)),
            _infoRow('Category', subscription.category),
            _infoRow(
              'Next renewal',
              '${subscription.nextRenewal.year}-${subscription.nextRenewal.month.toString().padLeft(2, '0')}-${subscription.nextRenewal.day.toString().padLeft(2, '0')}',
            ),
            if (subscription.isTrial && subscription.trialEndDate != null)
              _infoRow(
                'Trial ends',
                '${subscription.trialEndDate!.year}-${subscription.trialEndDate!.month.toString().padLeft(2, '0')}-${subscription.trialEndDate!.day.toString().padLeft(2, '0')}',
              ),
            if (subscription.notes != null && subscription.notes!.isNotEmpty)
              _infoRow('Notes', subscription.notes!),
            if (subscription.isArchived)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.archive_outlined, size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This subscription is archived. Use the unarchive icon above to restore it.',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(color: Colors.grey[600]))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}