import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../widgets/subscription_card.dart';
import 'subscription_detail_screen.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubscriptionProvider>();
    final archived = provider.subscriptions.where((s) => s.isArchived).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Archive')),
      body: archived.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 56, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Nothing archived',
                      style: TextStyle(color: Colors.grey[600], fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Archived subscriptions will show up here',
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: archived.length,
              itemBuilder: (context, index) {
                final s = archived[index];
                return SubscriptionCard(
                  subscription: s,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SubscriptionDetailScreen(subscription: s)),
                  ),
                );
              },
            ),
    );
  }
}