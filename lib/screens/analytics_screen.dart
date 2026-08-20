import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/subscription_provider.dart';
import '../providers/currency_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  static const List<Color> _chartColors = [
    Color(0xFF3D5AFE),
    Color(0xFF00C9A7),
    Color(0xFFFF6D00),
    Color(0xFFE53935),
    Color(0xFF8E24AA),
    Color(0xFF00ACC1),
    Color(0xFFFDD835),
  ];

  @override
  Widget build(BuildContext context) {
    final subProvider = context.watch<SubscriptionProvider>();
    final currencyProvider = context.watch<CurrencyProvider>();
    final symbol = currencyProvider.currency.symbol;

    final active = subProvider.subscriptions.where((s) => !s.isArchived).toList();

    if (active.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analytics')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bar_chart_outlined, size: 56, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No data yet',
                  style: TextStyle(color: Colors.grey[600], fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add a subscription to see spending analytics',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Group monthly spend by category.
    final Map<String, double> byCategory = {};
    for (final s in active) {
      byCategory[s.category] = (byCategory[s.category] ?? 0) + s.monthlyCost;
    }
    final categoryEntries = byCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final totalMonthly = active.fold(0.0, (sum, s) => sum + s.monthlyCost);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- Summary cards ----
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Monthly',
                  value: '$symbol${currencyProvider.convert(totalMonthly).toStringAsFixed(2)}',
                  color: const Color(0xFF3D5AFE),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Yearly',
                  value: '$symbol${currencyProvider.convert(totalMonthly * 12).toStringAsFixed(2)}',
                  color: const Color(0xFF00C9A7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ---- Category breakdown pie chart ----
          const Text('Spending by category', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: List.generate(categoryEntries.length, (i) {
                        final entry = categoryEntries[i];
                        final percent = totalMonthly == 0 ? 0.0 : (entry.value / totalMonthly * 100);
                        return PieChartSectionData(
                          value: entry.value,
                          color: _chartColors[i % _chartColors.length],
                          title: '${percent.toStringAsFixed(0)}%',
                          radius: 50,
                          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                        );
                      }),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    itemCount: categoryEntries.length,
                    itemBuilder: (context, i) {
                      final entry = categoryEntries[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(width: 10, height: 10, decoration: BoxDecoration(color: _chartColors[i % _chartColors.length], shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(entry.key, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ---- Category list with amounts ----
          const Text('Category breakdown', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          ...List.generate(categoryEntries.length, (i) {
            final entry = categoryEntries[i];
            final percent = totalMonthly == 0 ? 0.0 : (entry.value / totalMonthly);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('$symbol${currencyProvider.convert(entry.value).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 6,
                      backgroundColor: Colors.grey[200],
                      color: _chartColors[i % _chartColors.length],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}