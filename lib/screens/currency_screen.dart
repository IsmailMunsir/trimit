import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/currency.dart';
import '../providers/currency_provider.dart';

class CurrencyScreen extends StatelessWidget {
  const CurrencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CurrencyProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Currency')),
      body: ListView.builder(
        itemCount: kSupportedCurrencies.length,
        itemBuilder: (context, index) {
          final currency = kSupportedCurrencies[index];
          final selected = currency.code == provider.currency.code;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: selected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15) : Colors.grey[100],
              child: Text(
                currency.symbol,
                style: TextStyle(
                  color: selected ? Theme.of(context).colorScheme.primary : Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(currency.name),
            subtitle: Text(currency.code),
            trailing: selected ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary) : null,
            onTap: () => context.read<CurrencyProvider>().setCurrency(currency),
          );
        },
      ),
    );
  }
}