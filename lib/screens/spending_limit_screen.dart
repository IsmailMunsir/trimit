import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/spending_limit_provider.dart';
import '../providers/currency_provider.dart';

class SpendingLimitScreen extends StatefulWidget {
  const SpendingLimitScreen({super.key});

  @override
  State<SpendingLimitScreen> createState() => _SpendingLimitScreenState();
}

class _SpendingLimitScreenState extends State<SpendingLimitScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final currentLimit = context.read<SpendingLimitProvider>().limit;
    final currencyProvider = context.read<CurrencyProvider>();
    _controller = TextEditingController(
      text: currentLimit != null ? currencyProvider.convert(currentLimit).toStringAsFixed(2) : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final currencyProvider = context.read<CurrencyProvider>();
    final limitProvider = context.read<SpendingLimitProvider>();
    final text = _controller.text.trim();

    if (text.isEmpty) {
      await limitProvider.setLimit(null);
    } else {
      final entered = double.tryParse(text);
      if (entered == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid number')),
        );
        return;
      }
      final rate = currencyProvider.convert(1.0);
      final limitInUsd = rate == 0 ? entered : entered / rate;
      await limitProvider.setLimit(limitInUsd);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Spending limit updated')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final symbol = context.watch<CurrencyProvider>().currency.symbol;

    return Scaffold(
      appBar: AppBar(title: const Text('Spending Limit')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get notified when your total monthly spending goes over this amount. Leave blank to turn this off.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Monthly limit', prefixText: '$symbol '),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}