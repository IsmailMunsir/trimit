import 'package:flutter/material.dart';
import '../models/subscription.dart';
import '../utils/service_icons.dart';

class SubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback onTap;

  const SubscriptionCard({super.key, required this.subscription, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final daysLeft = subscription.nextRenewal.difference(DateTime.now()).inDays;
    final known = findKnownService(subscription.name);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Shows the real brand icon (via simple_icons) when the name
              // matches a known service; otherwise falls back to a colored
              // circle with the subscription's first letter.
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Color(subscription.colorValue).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: known != null
                    ? Icon(known.iconData, color: Color(subscription.colorValue), size: 22)
                    : Text(
                        subscription.name.isNotEmpty ? subscription.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: Color(subscription.colorValue),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            subscription.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                        ),
                        if (subscription.isFavorite) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      daysLeft <= 0 ? 'Renews today' : 'Renews in $daysLeft days',
                      style: TextStyle(
                        color: daysLeft <= 3 ? Colors.red : Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${subscription.cost.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}