import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';

class AddSubscriptionScreen extends StatefulWidget {
  final Subscription? existing;

  const AddSubscriptionScreen({super.key, this.existing});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _costController;

  late BillingCycle _selectedCycle;
  late String _selectedCategory;
  late DateTime _nextRenewal;
  bool _isSaving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _costController = TextEditingController(
      text: existing != null ? existing.cost.toStringAsFixed(2) : '',
    );
    _selectedCycle = existing?.cycle ?? BillingCycle.monthly;
    _selectedCategory = existing?.category ?? kCategories.first;
    _nextRenewal = existing?.nextRenewal ?? DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextRenewal,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 1095)),
    );
    if (picked != null) {
      setState(() => _nextRenewal = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = context.read<SubscriptionProvider>();

    final subscription = Subscription(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      cost: double.parse(_costController.text.trim()),
      cycle: _selectedCycle,
      category: _selectedCategory,
      nextRenewal: _nextRenewal,
    );

    try {
      await provider.addOrUpdate(subscription);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Subscription' : 'Add Subscription')),
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
              onPressed: _isSaving ? null : _save,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isSaving
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_isEditing ? 'Save Changes' : 'Save Subscription'),
            ),
          ],
        ),
      ),
    );
  }
}