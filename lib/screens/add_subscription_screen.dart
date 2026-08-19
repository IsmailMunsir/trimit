import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../utils/service_icons.dart';

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
  late final TextEditingController _notesController;

  late BillingCycle _selectedCycle;
  late String _selectedCategory;
  late DateTime _nextRenewal;
  late int _selectedColor;
  late bool _isTrial;
  DateTime? _trialEndDate;
  late bool _reminderEnabled;
  late int _reminderDaysBefore;
  late SubscriptionStatus _selectedStatus;
  late bool _isFavorite;
  bool _isSaving = false;

  bool _colorWasAutoDetected = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _costController = TextEditingController(
      text: existing != null ? existing.cost.toStringAsFixed(2) : '',
    );
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _selectedCycle = existing?.cycle ?? BillingCycle.monthly;
    _selectedCategory = existing?.category ?? kCategories.first;
    _nextRenewal = existing?.nextRenewal ?? DateTime.now().add(const Duration(days: 30));
    _selectedColor = existing?.colorValue ?? kAvatarColors.first;
    _isTrial = existing?.isTrial ?? false;
    _trialEndDate = existing?.trialEndDate;
    _reminderEnabled = existing?.reminderEnabled ?? true;
    _reminderDaysBefore = existing?.reminderDaysBefore ?? 2;
    _selectedStatus = existing?.status ?? SubscriptionStatus.active;
    _isFavorite = existing?.isFavorite ?? false;

    if (!_isEditing) {
      _nameController.addListener(_onNameChanged);
    }
  }

  void _onNameChanged() {
    final match = findKnownService(_nameController.text);
    if (match != null) {
      setState(() {
        _selectedColor = match.colorValue;
        _colorWasAutoDetected = true;
      });
    } else if (_colorWasAutoDetected) {
      setState(() {
        _colorWasAutoDetected = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextRenewal,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 1095)),
    );
    if (picked != null) setState(() => _nextRenewal = picked);
  }

  Future<void> _pickTrialEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _trialEndDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _trialEndDate = picked);
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _statusLabel(SubscriptionStatus s) {
    switch (s) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.trial:
        return 'Trial';
      case SubscriptionStatus.paused:
        return 'Paused';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
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
      colorValue: _selectedColor,
      isTrial: _isTrial,
      trialEndDate: _isTrial ? _trialEndDate : null,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      reminderEnabled: _reminderEnabled,
      reminderDaysBefore: _reminderDaysBefore,
      status: _selectedStatus,
      isFavorite: _isFavorite,
      isArchived: widget.existing?.isArchived ?? false,
    );

    try {
      await provider.addOrUpdate(subscription);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Subscription' : 'Add Subscription'),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.star : Icons.star_border, color: _isFavorite ? Colors.amber : null),
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name (e.g. Spotify)'),
              validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 16),

            // ---- Logo color picker ----
            const Text('Logo color', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: kAvatarColors.map((c) {
                final selected = c == _selectedColor;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedColor = c;
                    _colorWasAutoDetected = false;
                  }),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color(c),
                      shape: BoxShape.circle,
                      border: selected ? Border.all(color: Colors.black87, width: 2.5) : null,
                    ),
                    child: selected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

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
              items: kCategories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<SubscriptionStatus>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(labelText: 'Status'),
              items: SubscriptionStatus.values
                  .map((s) => DropdownMenuItem(value: s, child: Text(_statusLabel(s))))
                  .toList(),
              onChanged: (value) => setState(() => _selectedStatus = value!),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Next renewal date'),
                child: Text(_formatDate(_nextRenewal)),
              ),
            ),
            const SizedBox(height: 16),

            // ---- Free trial ----
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('This is a free trial'),
              value: _isTrial,
              onChanged: (v) => setState(() => _isTrial = v),
            ),
            if (_isTrial)
              InkWell(
                onTap: _pickTrialEndDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Trial ends on'),
                  child: Text(_trialEndDate != null ? _formatDate(_trialEndDate!) : 'Select a date'),
                ),
              ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // ---- Reminder preferences ----
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Remind me before renewal'),
              value: _reminderEnabled,
              onChanged: (v) => setState(() => _reminderEnabled = v),
            ),
            if (_reminderEnabled)
              DropdownButtonFormField<int>(
                initialValue: _reminderDaysBefore,
                decoration: const InputDecoration(labelText: 'Remind me (days before)'),
                items: [1, 2, 3, 5, 7]
                    .map((d) => DropdownMenuItem(value: d, child: Text('$d day${d == 1 ? '' : 's'} before')))
                    .toList(),
                onChanged: (v) => setState(() => _reminderDaysBefore = v!),
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