import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../widgets/subscription_card.dart';
import 'subscription_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubscriptionProvider>();
    final favorites = provider.subscriptions.where((s) => s.isFavorite && !s.isArchived).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favorites.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_border, size: 56, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'No favorites yet',
                      style: TextStyle(color: Colors.grey[600], fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap the star on any subscription to pin it here',
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final s = favorites[index];
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