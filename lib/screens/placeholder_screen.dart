import 'package:flutter/material.dart';

/// A simple "coming soon" screen used for nav tabs we haven't built yet.
/// Each real screen in later phases will replace one of these.
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderScreen({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('$title coming soon', style: TextStyle(color: Colors.grey[500], fontSize: 15)),
          ],
        ),
      ),
    );
  }
}