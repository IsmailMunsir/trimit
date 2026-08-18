enum BillingCycle { weekly, monthly, yearly }

class Subscription {
  final String id;
  final String name;
  final double cost;
  final BillingCycle cycle;
  final String category;
  final DateTime nextRenewal;
  final int colorValue; // stored as an int so it can be saved to the database
  final bool isTrial;
  final DateTime? trialEndDate;
  final String? notes;
  final bool reminderEnabled;
  final int reminderDaysBefore;

  Subscription({
    required this.id,
    required this.name,
    required this.cost,
    required this.cycle,
    required this.category,
    required this.nextRenewal,
    this.colorValue = 0xFF3D5AFE, // default brand blue if none chosen
    this.isTrial = false,
    this.trialEndDate,
    this.notes,
    this.reminderEnabled = true,
    this.reminderDaysBefore = 2,
  });

  /// Converts any billing cycle into an equivalent monthly cost,
  /// so we can show one consistent "total per month" number later.
  double get monthlyCost {
    switch (cycle) {
      case BillingCycle.weekly:
        return cost * 52 / 12;
      case BillingCycle.monthly:
        return cost;
      case BillingCycle.yearly:
        return cost / 12;
    }
  }

  Subscription copyWith({
    String? name,
    double? cost,
    BillingCycle? cycle,
    String? category,
    DateTime? nextRenewal,
    int? colorValue,
    bool? isTrial,
    DateTime? trialEndDate,
    String? notes,
    bool? reminderEnabled,
    int? reminderDaysBefore,
  }) {
    return Subscription(
      id: id,
      name: name ?? this.name,
      cost: cost ?? this.cost,
      cycle: cycle ?? this.cycle,
      category: category ?? this.category,
      nextRenewal: nextRenewal ?? this.nextRenewal,
      colorValue: colorValue ?? this.colorValue,
      isTrial: isTrial ?? this.isTrial,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      notes: notes ?? this.notes,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
    );
  }
}

const List<String> kCategories = [
  'Streaming',
  'Music',
  'Software',
  'Gaming',
  'Fitness',
  'Other',
];

/// A small curated palette for the subscription "logo" color picker.
const List<int> kAvatarColors = [
  0xFF3D5AFE, // blue
  0xFFE53935, // red
  0xFF43A047, // green
  0xFFFF6D00, // orange
  0xFF8E24AA, // purple
  0xFF00ACC1, // teal
  0xFFFDD835, // yellow
  0xFF6D4C41, // brown
];