import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/subscription.dart';
import 'providers/subscription_provider.dart';
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

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  Future<void> _openAddScreen(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddSubscriptionScreen()),
    );
    // No manual reload needed anymore — addOrUpdate() inside the provider
    // already calls notifyListeners(), so this screen rebuilds automatically.
  }

  Future<void> _openDetailScreen(BuildContext context, Subscription s) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SubscriptionDetailScreen(subscription: s)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // context.watch<...>() means "rebuild this screen whenever the provider changes"
    final provider = context.watch<SubscriptionProvider>();

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
                SummaryCard(totalMonthly: provider.totalMonthly),
                const SizedBox(height: 20),
                const Text(
                  'Your subscriptions',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                ),
                const SizedBox(height: 8),
                if (provider.subscriptions.isEmpty)
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
                  ...provider.subscriptions.map((s) => SubscriptionCard(
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