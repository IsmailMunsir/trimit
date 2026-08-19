import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wallet.dart';
import '../providers/wallet_provider.dart';
import '../providers/subscription_provider.dart';
import '../widgets/subscription_card.dart';
import 'add_wallet_screen.dart';
import 'subscription_detail_screen.dart';

class WalletDetailScreen extends StatelessWidget {
  final Wallet wallet;
  const WalletDetailScreen({super.key, required this.wallet});

  Future<void> _confirmDelete(BuildContext context) async {
    final provider = context.read<WalletProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete wallet?'),
        content: Text(
          'This will delete "${wallet.name}". Subscriptions inside it will not be deleted — they\'ll just no longer be grouped under this wallet.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.delete(wallet.id);
      if (context.mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subProvider = context.watch<SubscriptionProvider>();
    final subs = subProvider.subscriptions.where((s) => s.walletId == wallet.id && !s.isArchived).toList();
    final total = subs.fold(0.0, (sum, s) => sum + s.monthlyCost);

    return Scaffold(
      appBar: AppBar(
        title: Text(wallet.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddWalletScreen(existing: wallet)),
              );
              if (result == true && context.mounted) Navigator.pop(context, true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(wallet.colorValue).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total in this wallet', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                const SizedBox(height: 6),
                Text(
                  '\$${total.toStringAsFixed(2)}/mo',
                  style: TextStyle(color: Color(wallet.colorValue), fontSize: 28, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          Expanded(
            child: subs.isEmpty
                ? Center(
                    child: Text(
                      'No subscriptions in this wallet yet',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: subs.length,
                    itemBuilder: (context, index) {
                      final s = subs[index];
                      return SubscriptionCard(
                        subscription: s,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SubscriptionDetailScreen(subscription: s)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}