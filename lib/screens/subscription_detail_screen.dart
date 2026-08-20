import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../providers/currency_provider.dart';
import 'add_subscription_screen.dart';
import 'payment_history_screen.dart';

class SubscriptionDetailScreen extends StatefulWidget {
  final Subscription subscription;

  const SubscriptionDetailScreen({super.key, required this.subscription});

  @override
  State<SubscriptionDetailScreen> createState() => _SubscriptionDetailScreenState();
}

class _SubscriptionDetailScreenState extends State<SubscriptionDetailScreen> {
  late Subscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.subscription;
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final provider = context.read<SubscriptionProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete subscription?'),
        content: Text('This will remove "${_subscription.name}" permanently.'),
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
      await provider.delete(_subscription.id);
      if (context.mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _toggleArchive(BuildContext context) async {
    final provider = context.read<SubscriptionProvider>();
    final updated = _subscription.copyWith(isArchived: !_subscription.isArchived);
    await provider.addOrUpdate(updated);
    if (context.mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _adjustRenewalDate(BuildContext context) async {
    final provider = context.read<SubscriptionProvider>();

    final picked = await showDatePicker(
      context: context,
      initialDate: _subscription.nextRenewal,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 1095)),
      helpText: 'Adjust renewal date',
    );

    if (picked == null) return;

    final updated = _subscription.copyWith(nextRenewal: picked);
    await provider.addOrUpdate(updated);

    // Update this screen's own copy so the new date shows immediately,
    // without needing to back out and reopen the subscription.
    if (mounted) {
      setState(() => _subscription = updated);
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
      case SubscriptionStatus.expired:
        return 'Expired';
    }
  }

  Color _statusColor(SubscriptionStatus s) {
    switch (s) {
      case SubscriptionStatus.active:
        return Colors.green;
      case SubscriptionStatus.trial:
        return Colors.blue;
      case SubscriptionStatus.paused:
        return Colors.orange;
      case SubscriptionStatus.cancelled:
        return Colors.red;
      case SubscriptionStatus.expired:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();
    final symbol = currencyProvider.currency.symbol;
    final convertedCost = currencyProvider.convert(_subscription.cost);

    return Scaffold(
      appBar: AppBar(
        title: Text(_subscription.name),
        actions: [
          if (!_subscription.isArchived)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddSubscriptionScreen(existing: _subscription),
                  ),
                );
                if (result == true && context.mounted) {
                  Navigator.pop(context, true);
                }
              },
            ),
          IconButton(
            icon: Icon(_subscription.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined),
            tooltip: _subscription.isArchived ? 'Unarchive' : 'Archive',
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
                  '$symbol${convertedCost.toStringAsFixed(2)} / ${_subscription.cycle.name}',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                ),
                if (_subscription.isFavorite) ...[
                  const SizedBox(width: 10),
                  const Icon(Icons.star, color: Colors.amber, size: 22),
                ],
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  SizedBox(width: 120, child: Text('Status', style: TextStyle(color: Colors.grey[600]))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(_subscription.status).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _statusLabel(_subscription.status),
                      style: TextStyle(color: _statusColor(_subscription.status), fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            _infoRow('Category', _subscription.category),
            InkWell(
              onTap: () => _adjustRenewalDate(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(width: 120, child: Text('Next renewal', style: TextStyle(color: Colors.grey[600]))),
                    Expanded(
                      child: Text(_formatDate(_subscription.nextRenewal), style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    Icon(Icons.edit_calendar_outlined, size: 18, color: Colors.grey[500]),
                  ],
                ),
              ),
            ),
            if (_subscription.isTrial && _subscription.trialEndDate != null)
              _infoRow('Trial ends', _formatDate(_subscription.trialEndDate!)),
            if (_subscription.notes != null && _subscription.notes!.isNotEmpty)
              _infoRow('Notes', _subscription.notes!),
            if (_subscription.isArchived)
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
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PaymentHistoryScreen(subscription: _subscription)),
              ),
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('View Payment History'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 0),
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