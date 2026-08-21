import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wallet.dart';
import '../providers/wallet_provider.dart';
import '../providers/subscription_provider.dart';
import 'add_wallet_screen.dart';
import 'wallet_detail_screen.dart';

class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final subProvider = context.watch<SubscriptionProvider>();
    final wallets = walletProvider.wallets;

    double totalFor(Wallet w) {
      return subProvider.subscriptions
          .where((s) => s.walletId == w.id && !s.isArchived)
          .fold(0.0, (sum, s) => sum + s.monthlyCost);
    }

    int countFor(Wallet w) {
      return subProvider.subscriptions.where((s) => s.walletId == w.id && !s.isArchived).length;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Wallets')),
            floatingActionButton: FloatingActionButton(
        heroTag: 'wallets_fab',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddWalletScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: walletProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : wallets.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.account_balance_wallet_outlined, size: 56, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No wallets yet',
                          style: TextStyle(color: Colors.grey[600], fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Create a wallet to group subscriptions,\nlike "Personal" or "Family"',
                          style: TextStyle(color: Colors.grey[400], fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: wallets.length,
                  itemBuilder: (context, index) {
                    final w = wallets[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => WalletDetailScreen(wallet: w)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Color(w.colorValue).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Icon(Icons.account_balance_wallet_outlined, color: Color(w.colorValue)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(w.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${countFor(w)} subscription${countFor(w) == 1 ? '' : 's'}',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '\$${totalFor(w).toStringAsFixed(2)}/mo',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}