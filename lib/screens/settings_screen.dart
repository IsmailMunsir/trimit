import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../providers/spending_limit_provider.dart';
import '../providers/auth_provider.dart';
import 'favorites_screen.dart';
import 'archive_screen.dart';
import 'wallets_screen.dart';
import 'currency_settings_screen.dart';
import 'spending_limit_screen.dart';
import 'privacy_security_screen.dart';
import 'theme_settings_screen.dart';
import 'about_screen.dart';
import 'auth/profile_screen.dart';
import 'auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>().currency;
    final currencyProvider = context.watch<CurrencyProvider>();
    final limit = context.watch<SpendingLimitProvider>().limit;
    final limitText = limit != null
        ? '${currency.symbol}${currencyProvider.convert(limit).toStringAsFixed(0)}'
        : 'Off';
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SettingsTile(
            icon: Icons.person_outline,
            iconColor: Colors.indigo,
            label: isLoggedIn ? 'Profile' : 'Log in',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => isLoggedIn ? const ProfileScreen() : const LoginScreen(),
              ),
            ),
          ),
          const Divider(height: 1),
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
          _SettingsTile(
            icon: Icons.notifications_active_outlined,
            iconColor: Colors.deepPurple,
            label: 'Spending Limit Alert',
            trailingText: limitText,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SpendingLimitScreen()),
            ),
          ),
          const Divider(height: 1),
          _SettingsTile(
            icon: Icons.palette_outlined,
            iconColor: Colors.pink,
            label: 'Theme',
            trailingText: 'Light',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ThemeSettingsScreen()),
            ),
          ),
          _SettingsTile(
            icon: Icons.shield_outlined,
            iconColor: Colors.teal,
            label: 'Privacy & Security',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrivacySecurityScreen()),
            ),
          ),
          _SettingsTile(
            icon: Icons.help_outline,
            iconColor: Colors.orange,
            label: 'Help & About',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutScreen()),
            ),
          ),
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