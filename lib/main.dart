import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/subscription.dart';
import 'providers/subscription_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/currency_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/subscription_card.dart';
import 'widgets/summary_card.dart';
import 'screens/add_subscription_screen.dart';
import 'screens/subscription_detail_screen.dart';
import 'screens/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/profile_screen.dart';

void main() {
  runApp(const TrimItApp());
}

class TrimItApp extends StatelessWidget {
  const TrimItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SubscriptionProvider()..loadSubscriptions()),
        ChangeNotifierProvider(create: (context) => WalletProvider()..loadWallets()),
        ChangeNotifierProvider(create: (context) => CurrencyProvider()..load()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'TrimIt',
        theme: AppTheme.light(),
        home: const SplashScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openAddScreen(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddSubscriptionScreen()),
    );
  }

  Future<void> _openDetailScreen(BuildContext context, Subscription s) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SubscriptionDetailScreen(subscription: s)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubscriptionProvider>();
    final visibleSubs = provider.subscriptions.where((s) => !s.isArchived).toList();
    final visibleTotal = visibleSubs.fold(0.0, (sum, s) => sum + s.monthlyCost);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TrimIt'),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              if (auth.isLoggedIn) {
                return IconButton(
                  icon: const Icon(Icons.person_outline),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.login),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                ),
              );
            },
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SummaryCard(totalMonthly: visibleTotal),
                const SizedBox(height: 20),
                const Text(
                  'Your subscriptions',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                ),
                const SizedBox(height: 8),
                if (visibleSubs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 56, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'No subscriptions yet',
                          style: TextStyle(color: Colors.grey[700], fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap + to add your first one',
                          style: TextStyle(color: Colors.grey[500], fontSize: 13),
                        ),
                      ],
                    ),
                  )
                else
                  ...visibleSubs.map((s) => SubscriptionCard(
                        subscription: s,
                        onTap: () => _openDetailScreen(context, s),
                      )),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddScreen(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}