import 'package:flutter/material.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _InfoBlock(
            icon: Icons.storage_outlined,
            title: 'Where your data lives',
            body: 'All subscriptions, wallets, and account details are stored locally on this '
                'device, in a private database that other apps cannot access.',
          ),
          const _InfoBlock(
            icon: Icons.wifi_outlined,
            title: 'What goes over the internet',
            body: 'TrimIt makes one type of network request: fetching current currency exchange '
                'rates, so amounts can be shown correctly converted. No subscription data, account '
                'details, or personal information is ever sent as part of that request.',
          ),
          const _InfoBlock(
            icon: Icons.lock_outline,
            title: 'Passwords',
            body: 'Account passwords are never stored as plain text. They are transformed with a '
                'one-way hash before being saved, meaning even TrimIt itself cannot read your '
                'original password back.',
          ),
          const _InfoBlock(
            icon: Icons.delete_outline,
            title: 'Deleting your data',
            body: 'Uninstalling the app permanently removes all local data. You can also delete '
                'individual subscriptions or wallets at any time from within the app.',
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _InfoBlock({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 8),
          Text(body, style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.5)),
        ],
      ),
    );
  }
}