import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subscription.dart';
import '../models/payment_record.dart';
import '../providers/subscription_provider.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final Subscription subscription;
  const PaymentHistoryScreen({super.key, required this.subscription});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  late Future<List<PaymentRecord>> _future;
  bool _groupByYear = false;

  @override
  void initState() {
    super.initState();
    _future = context.read<SubscriptionProvider>().getPaymentHistory(widget.subscription.id);
  }

  String _monthYear(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  Map<String, List<PaymentRecord>> _grouped(List<PaymentRecord> records) {
    final map = <String, List<PaymentRecord>>{};
    for (final r in records) {
      final key = _groupByYear ? '${r.paidOn.year}' : _monthYear(r.paidOn);
      map.putIfAbsent(key, () => []).add(r);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: TextButton(
                onPressed: () => setState(() => _groupByYear = !_groupByYear),
                child: Text(_groupByYear ? 'Show monthly' : 'Show yearly'),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<PaymentRecord>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final records = snapshot.data ?? [];
          if (records.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 56, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'No payments recorded yet',
                      style: TextStyle(color: Colors.grey[600], fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Payments are logged automatically\nwhen a renewal date passes',
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final grouped = _grouped(records);
          final totalPaid = records.fold(0.0, (sum, r) => sum + r.amount);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total paid all-time', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(
                      '\$${totalPaid.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text('${records.length} payment${records.length == 1 ? '' : 's'}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ...grouped.entries.map((entry) {
                final groupTotal = entry.value.fold(0.0, (sum, r) => sum + r.amount);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          Text('\$${groupTotal.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...entry.value.map((r) => Card(
                            margin: const EdgeInsets.only(bottom: 6),
                            child: ListTile(
                              leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                              title: Text('\$${r.amount.toStringAsFixed(2)}'),
                              subtitle: Text(
                                '${r.paidOn.year}-${r.paidOn.month.toString().padLeft(2, '0')}-${r.paidOn.day.toString().padLeft(2, '0')}',
                              ),
                            ),
                          )),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}