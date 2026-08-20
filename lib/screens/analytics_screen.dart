import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/subscription_provider.dart';
import '../providers/currency_provider.dart';
import '../db/database_helper.dart';
import '../models/payment_record.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  static const List<Color> _chartColors = [
    Color(0xFF3D5AFE),
    Color(0xFF00C9A7),
    Color(0xFFFF6D00),
    Color(0xFFE53935),
    Color(0xFF8E24AA),
    Color(0xFF00ACC1),
    Color(0xFFFDD835),
  ];

  late Future<List<PaymentRecord>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = DatabaseHelper.instance.getAllPaymentRecords();
  }

  String _monthLabel(DateTime d) {
    const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    return months[d.month - 1];
  }

  /// Groups payment records into the last 6 calendar months (oldest first),
  /// filling in $0 for any month with no recorded payments.
  List<MapEntry<DateTime, double>> _lastSixMonths(List<PaymentRecord> records) {
    final now = DateTime.now();
    final months = List.generate(6, (i) {
      final target = DateTime(now.year, now.month - (5 - i), 1);
      return DateTime(target.year, target.month, 1);
    });

    return months.map((month) {
      final total = records
          .where((r) => r.paidOn.year == month.year && r.paidOn.month == month.month)
          .fold(0.0, (sum, r) => sum + r.amount);
      return MapEntry(month, total);
    }).toList();
  }

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

    final Map<String, double> byCategory = {};
    for (final s in active) {
      byCategory[s.category] = (byCategory[s.category] ?? 0) + s.monthlyCost;
    }
    final categoryEntries = byCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final totalMonthly = active.fold(0.0, (sum, s) => sum + s.monthlyCost);

    // ---- Savings insight candidates ----
    final mostExpensive = categoryEntries.isNotEmpty ? categoryEntries.first : null;
    final trialsEndingSoon = active.where((s) {
      if (!s.isTrial || s.trialEndDate == null) return false;
      final daysAway = s.trialEndDate!.difference(DateTime.now()).inDays;
      return daysAway >= 0 && daysAway <= 7;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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

          // ---- Savings insights ----
          if (mostExpensive != null || trialsEndingSoon.isNotEmpty) ...[
            const Text('Insights', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            if (mostExpensive != null)
              _InsightCard(
                icon: Icons.trending_up,
                color: Colors.orange,
                text: '${mostExpensive.key} is your biggest expense at $symbol${currencyProvider.convert(mostExpensive.value).toStringAsFixed(2)}/mo (${totalMonthly == 0 ? 0 : (mostExpensive.value / totalMonthly * 100).toStringAsFixed(0)}% of total)',
              ),
            for (final trial in trialsEndingSoon)
              _InsightCard(
                icon: Icons.timer_outlined,
                color: Colors.red,
                text: '${trial.name} trial ends in ${trial.trialEndDate!.difference(DateTime.now()).inDays} day(s) — cancel now if you don\'t want to keep it',
              ),
            const SizedBox(height: 24),
          ],

          // ---- Spending trend chart (from real payment history) ----
          const Text('Spending trend (last 6 months)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 16),
          FutureBuilder<List<PaymentRecord>>(
            future: _historyFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()));
              }
              final records = snapshot.data ?? [];
              final monthly = _lastSixMonths(records);
              final maxY = monthly.map((e) => e.value).fold(0.0, (a, b) => a > b ? a : b);

              if (maxY == 0) {
                return SizedBox(
                  height: 180,
                  child: Center(
                    child: Text(
                      'No payment history yet — this fills in as renewals happen',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: maxY * 1.2,
                    gridData: const FlGridData(show: true, drawVerticalLine: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= monthly.length) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(_monthLabel(monthly[index].key), style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(monthly.length, (i) => FlSpot(i.toDouble(), monthly[i].value)),
                        isCurved: true,
                        color: const Color(0xFF3D5AFE),
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(show: true, color: const Color(0xFF3D5AFE).withValues(alpha: 0.1)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),

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

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _InsightCard({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(color: color.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}