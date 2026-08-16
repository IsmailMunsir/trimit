import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/subscription.dart';
import '../db/database_helper.dart';

class AddSubscriptionScreen extends StatefulWidget {
  const AddSubscriptionScreen({super.key});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _costController = TextEditingController();

  BillingCycle _selectedCycle = BillingCycle.monthly;
  String _selectedCategory = kCategories.first;
  DateTime _nextRenewal = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    // Always clean up text controllers when the screen closes, to avoid memory leaks.
    _nameController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextRenewal,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 1095)), // ~3 years ahead
    );
    if (picked != null) {
      setState(() => _nextRenewal = picked);
    }
  }

  Future<void> _save() async {
    // Runs all the validator functions attached to the form fields below.
    // If any of them return an error message, this returns false and we stop.
    if (!_formKey.currentState!.validate()) return;

    final newSubscription = Subscription(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      cost: double.parse(_costController.text.trim()),
      cycle: _selectedCycle,
      category: _selectedCategory,
      nextRenewal: _nextRenewal,
    );

    await DatabaseHelper.instance.insertSubscription(newSubscription);

    if (mounted) {
      Navigator.pop(context, true); // true tells the previous screen "something changed, refresh"
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Subscription')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name (e.g. Spotify)'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _costController,
              decoration: const InputDecoration(labelText: 'Cost', prefixText: '\$ '),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Please enter a cost';
                if (double.tryParse(value.trim()) == null) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BillingCycle>(
              initialValue: _selectedCycle,
              decoration: const InputDecoration(labelText: 'Billing cycle'),
              items: BillingCycle.values
                  .map((cycle) => DropdownMenuItem(value: cycle, child: Text(cycle.name)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedCycle = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: kCategories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Next renewal date'),
                child: Text(
                  '${_nextRenewal.year}-${_nextRenewal.month.toString().padLeft(2, '0')}-${_nextRenewal.day.toString().padLeft(2, '0')}',
                ),
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Save Subscription'),
            ),
          ],
        ),
      ),
    );
  }
}