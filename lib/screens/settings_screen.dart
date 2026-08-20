import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import 'favorites_screen.dart';
import 'archive_screen.dart';
import 'wallets_screen.dart';
import 'currency_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>().currency;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SettingsTile(
            icon: Icons.account_balance_wallet_outlined,
            iconColor: Colors.blue,
            label: 'Wallets',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WalletsScreen()),
            ),
          ),
          _SettingsTile(
            icon: Icons.star_outline,
            iconColor: Colors.amber,
            label: 'Favorites',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavoritesScreen()),
            ),
          ),
          _SettingsTile(
            icon: Icons.archive_outlined,
            label: 'Archive',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ArchiveScreen()),
            ),
          ),
          _SettingsTile(
            icon: Icons.attach_money,
            iconColor: Colors.green,
            label: 'Currency',
            trailingText: currency.code,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CurrencySettingsScreen()),
            ),
          ),
          // More settings (Profile, Backup & Restore, Privacy, Theme, Help)
          // will be added here in later phases.
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String? trailingText;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    this.iconColor,
    required this.label,
    this.trailingText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.grey[700]),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText!, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }
}