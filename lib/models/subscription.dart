enum BillingCycle { weekly, monthly, yearly }

class Subscription {
  final String id;
  final String name;
  final double cost;
  final BillingCycle cycle;
  final String category;
  final DateTime nextRenewal;

  Subscription({
    required this.id,
    required this.name,
    required this.cost,
    required this.cycle,
    required this.category,
    required this.nextRenewal,
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
}

const List<String> kCategories = [
  'Streaming',
  'Music',
  'Software',
  'Gaming',
  'Fitness',
  'Other',
];