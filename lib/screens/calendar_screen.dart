import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../providers/currency_provider.dart';
import '../widgets/subscription_card.dart';
import 'subscription_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<Subscription> _subscriptionsOn(DateTime day, List<Subscription> all) {
    return all.where((s) => !s.isArchived && _sameDay(s.nextRenewal, day)).toList();
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final subProvider = context.watch<SubscriptionProvider>();
    context.watch<CurrencyProvider>();

    final allActive = subProvider.subscriptions.where((s) => !s.isArchived).toList();

    final selected = _selectedDay ?? DateTime.now();
    final subsOnSelectedDay = _subscriptionsOn(selected, allActive);

    final now = DateTime.now();
    final soon = now.add(const Duration(days: 7));
    final upcoming = allActive
        .where((s) => s.nextRenewal.isAfter(now) && s.nextRenewal.isBefore(soon))
        .toList()
      ..sort((a, b) => a.nextRenewal.compareTo(b.nextRenewal));

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          if (upcoming.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upcoming this week',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: upcoming.length,
                      itemBuilder: (context, index) {
                        final s = upcoming[index];
                        final daysAway = s.nextRenewal.difference(now).inDays;
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SubscriptionDetailScreen(subscription: s)),
                          ),
                          child: Container(
                            width: 130,
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(s.colorValue).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  s.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  daysAway <= 0 ? 'Today' : 'in $daysAway day${daysAway == 1 ? '' : 's'}',
                                  style: TextStyle(
                                    color: daysAway <= 2 ? Colors.red : Colors.grey[600],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TableCalendar<Subscription>(
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 730)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => _selectedDay != null && _sameDay(day, _selectedDay!),
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {CalendarFormat.month: 'Month'},
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                eventLoader: (day) {
                  final normalized = DateTime(day.year, day.month, day.day);
                  return _subscriptionsOn(normalized, allActive);
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 1,
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${selected.year}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const Spacer(),
                Text(
                  '${subsOnSelectedDay.length} renewal${subsOnSelectedDay.length == 1 ? '' : 's'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: subsOnSelectedDay.isEmpty
                ? Center(
                    child: Text(
                      'Nothing renews on this day',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: subsOnSelectedDay.length,
                    itemBuilder: (context, index) {
                      final s = subsOnSelectedDay[index];
                      return SubscriptionCard(
                        subscription: s,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SubscriptionDetailScreen(subscription: s)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}