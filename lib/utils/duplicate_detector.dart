import '../models/subscription.dart';

class DuplicateGroup {
  final String name;
  final List<Subscription> subscriptions;

  DuplicateGroup({required this.name, required this.subscriptions});
}

/// Flags subscriptions that share the same name (case-insensitive) and are
/// both still active — a strong signal of an accidental duplicate entry,
/// e.g. adding "Netflix" twice by mistake.
List<DuplicateGroup> findDuplicates(List<Subscription> all) {
  final active = all.where((s) => !s.isArchived).toList();
  final Map<String, List<Subscription>> byName = {};

  for (final s in active) {
    final key = s.name.trim().toLowerCase();
    byName.putIfAbsent(key, () => []).add(s);
  }

  return byName.entries
      .where((entry) => entry.value.length > 1)
      .map((entry) => DuplicateGroup(name: entry.value.first.name, subscriptions: entry.value))
      .toList();
}