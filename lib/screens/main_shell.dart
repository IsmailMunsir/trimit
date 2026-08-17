import 'package:flutter/material.dart';
import 'placeholder_screen.dart';
import '../main.dart' show HomeScreen;
import '../widgets/custom_nav_bar.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    PlaceholderScreen(title: 'Subscriptions', icon: Icons.receipt_long_outlined),
    PlaceholderScreen(title: 'Calendar', icon: Icons.calendar_month_outlined),
    PlaceholderScreen(title: 'Analytics', icon: Icons.bar_chart_outlined),
    PlaceholderScreen(title: 'Settings', icon: Icons.settings_outlined),
  ];

  final List<NavItem> _navItems = const [
    NavItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
    NavItem(icon: Icons.receipt_long_outlined, selectedIcon: Icons.receipt_long, label: 'Subscriptions'),
    NavItem(icon: Icons.calendar_month_outlined, selectedIcon: Icons.calendar_month, label: 'Calendar'),
    NavItem(icon: Icons.bar_chart_outlined, selectedIcon: Icons.bar_chart, label: 'Analytics'),
    NavItem(icon: Icons.settings_outlined, selectedIcon: Icons.settings, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: _navItems,
      ),
    );
  }
}