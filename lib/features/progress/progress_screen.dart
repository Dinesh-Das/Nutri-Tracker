import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/models/meal_entry.dart';
import 'package:nutri_tracker/models/weight_entry.dart';
import 'package:nutri_tracker/services/calorie_service.dart';
import 'package:nutri_tracker/services/firestore_service.dart';
import 'package:nutri_tracker/widgets/macro_chart_widget.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null)
      return const Scaffold(body: Center(child: Text('Please sign in.')));
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: FutureBuilder<List<WeightEntry>>(
        future: FirestoreService().getWeightHistory(uid),
        builder: (context, snapshot) {
          final entries = snapshot.data ?? [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ChartCard(
                title: 'BMI History',
                child: entries.isEmpty
                    ? const _EmptyState(text: 'No BMI entries yet.')
                    : LineChart(_bmiChart(entries)),
              ),
              _ChartCard(
                title: 'Weight Trend',
                child: entries.isEmpty
                    ? const _EmptyState(text: 'No weight entries yet.')
                    : BarChart(_weightChart(entries.take(7).toList())),
              ),
              _WeeklyCalories(uid: uid),
              _TodayMacros(uid: uid),
              Row(
                children: [
                  Expanded(child: _LogStreak(uid: uid)),
                  Expanded(
                      child: _StatCard(
                          label: 'BMI checks', value: '${entries.length}')),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  LineChartData _bmiChart(List<WeightEntry> entries) {
    return LineChartData(
      minY: 15,
      maxY: 35,
      gridData: const FlGridData(show: true),
      titlesData: const FlTitlesData(
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          spots: [
            for (var i = 0; i < entries.length; i++)
              FlSpot(i.toDouble(), entries[i].bmi),
          ],
          dotData: const FlDotData(show: true),
        ),
      ],
      extraLinesData: ExtraLinesData(horizontalLines: [
        HorizontalLine(y: 18.5, color: Colors.blue.withOpacity(0.5)),
        HorizontalLine(y: 25, color: Colors.green.withOpacity(0.5)),
        HorizontalLine(y: 30, color: Colors.orange.withOpacity(0.5)),
      ]),
    );
  }

  BarChartData _weightChart(List<WeightEntry> entries) {
    return BarChartData(
      titlesData: const FlTitlesData(
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      barGroups: [
        for (var i = 0; i < entries.length; i++)
          BarChartGroupData(
            x: i,
            barRods: [BarChartRodData(toY: entries[i].weight, width: 14)],
          ),
      ],
    );
  }
}

class _LogStreak extends StatelessWidget {
  const _LogStreak({required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DailyCalorieLog>>(
      future: Future.wait(List.generate(30, (index) {
        return CalorieService().getDailyLog(
          uid,
          DateTime.now().subtract(Duration(days: index)),
        );
      })),
      builder: (context, snapshot) {
        final logs = snapshot.data ?? const <DailyCalorieLog>[];
        var streak = 0;
        for (final log in logs) {
          if (log.totalCalories > 0 || log.meals.isNotEmpty) {
            streak++;
          } else {
            break;
          }
        }
        return _StatCard(label: 'Log streak', value: '$streak days');
      },
    );
  }
}

class _WeeklyCalories extends StatelessWidget {
  const _WeeklyCalories({required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: 'Weekly Calories',
      child: FutureBuilder(
        future: Future.wait(List.generate(7, (index) {
          final date = DateTime.now().subtract(Duration(days: 6 - index));
          return CalorieService().getDailyLog(uid, date);
        })),
        builder: (context, snapshot) {
          final logs = snapshot.data ?? [];
          if (logs.every((log) => log.totalCalories == 0)) {
            return const _EmptyState(text: 'No calorie logs this week.');
          }
          return BarChart(
            BarChartData(
              barGroups: [
                for (var i = 0; i < logs.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                          toY: logs[i].totalCalories.toDouble(), width: 9),
                      BarChartRodData(toY: 2000, width: 9, color: Colors.grey),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TodayMacros extends StatelessWidget {
  const _TodayMacros({required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: CalorieService().watchDailyLog(uid, DateTime.now()),
      builder: (context, snapshot) {
        final log = snapshot.data;
        return _ChartCard(
          title: 'Macro Distribution',
          child: MacroChartWidget(
            protein: log?.totalProtein ?? 0,
            carbs: log?.totalCarbs ?? 0,
            fat: log?.totalFat ?? 0,
            size: 190,
          ),
        );
      },
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(height: 220, child: child),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Center(child: Text(text));
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            Text(label),
          ],
        ),
      ),
    );
  }
}
