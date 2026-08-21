import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../utils/duplicate_detector.dart';
import '../widgets/subscription_card.dart';
import 'subscription_detail_screen.dart';

class DuplicatesScreen extends StatelessWidget {
  const DuplicatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subProvider = context.watch<SubscriptionProvider>();
    final groups = findDuplicates(subProvider.subscriptions);

    return Scaffold(
      appBar: AppBar(title: const Text('Possible Duplicates')),
      body: groups.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline, size: 56, color: Colors.green[300]),
                    const SizedBox(height: 16),
                    Text(
                      'No duplicates found',
                      style: TextStyle(color: Colors.grey[600], fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Every active subscription has a unique name',
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: groups.map((group) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            '${group.subscriptions.length}x "${group.name}"',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...group.subscriptions.map((s) => SubscriptionCard(
                            subscription: s,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SubscriptionDetailScreen(subscription: s)),
                            ),
                          )),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}