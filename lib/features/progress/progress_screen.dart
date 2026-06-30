import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_tracker/models/meal_entry.dart';
import 'package:nutri_tracker/models/workout_entry.dart';
import 'package:nutri_tracker/models/weight_entry.dart';
import 'package:nutri_tracker/services/calorie_service.dart';
import 'package:nutri_tracker/services/firestore_service.dart';
import 'package:nutri_tracker/routes/app_routes.dart';
import 'package:nutri_tracker/services/workout_service.dart';
import 'package:nutri_tracker/widgets/macro_chart_widget.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please sign in.')));
    }
    return Scaffold(
      appBar: showAppBar ? AppBar(title: const Text('Progress')) : null,
      body: FutureBuilder<List<WeightEntry>>(
        future: FirestoreService().getWeightHistory(uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Unable to load progress: ${snapshot.error}'),
            );
          }
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
              _WeeklyWorkouts(uid: uid),
              _TodayMacros(uid: uid),
              Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.emoji_events)),
                  title: const Text('Achievements'),
                  subtitle: const Text('View badges and milestones'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.achievements),
                ),
              ),
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

class _WeeklyWorkouts extends StatelessWidget {
  const _WeeklyWorkouts({required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 6));
    final end = start.add(const Duration(days: 7));
    return _ChartCard(
      title: 'Weekly Workouts',
      child: StreamBuilder<List<ExerciseEntry>>(
        stream: WorkoutService().watchWorkoutsInRange(
          uid,
          start: start,
          end: end,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _EmptyState(text: 'Unable to load workouts.');
          }
          final entries = snapshot.data ?? const <ExerciseEntry>[];
          if (entries.isEmpty) {
            return const _EmptyState(text: 'No workouts this week.');
          }
          final buckets = List.filled(7, 0);
          for (final entry in entries) {
            final dayOffset =
                entry.timestamp.difference(start).inDays.clamp(0, 6).toInt();
            buckets[dayOffset] += entry.caloriesBurned;
          }
          return BarChart(
            BarChartData(
              titlesData: const FlTitlesData(
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barGroups: [
                for (var i = 0; i < 7; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: buckets[i].toDouble(),
                        width: 12,
                      ),
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

class _LogStreak extends StatelessWidget {
  const _LogStreak({required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: CalorieService().getLogStreak(uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _StatCard(label: 'Log streak', value: '--');
        }
        final streak = snapshot.data ?? 0;
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
    return FutureBuilder(
      future: FirestoreService().getUser(uid),
      builder: (context, userSnapshot) {
        if (userSnapshot.hasError) {
          return const _ChartCard(
            title: 'Weekly Calories',
            child: Center(child: Text('Unable to load goal.')),
          );
        }
        final goal = userSnapshot.data?.dailyCalorieGoal ?? 2000;
        final today = DateTime.now();
        final start = today.subtract(const Duration(days: 6));
        return _ChartCard(
          title: 'Weekly Calories',
          child: FutureBuilder<List<DailyCalorieLog>>(
            future: CalorieService().getDailyLogsInRange(
              uid,
              start: start,
              end: today,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Unable to load calories: ${snapshot.error}'),
                );
              }
              final logsByDate = {
                for (final log in snapshot.data ?? const <DailyCalorieLog>[])
                  log.date: log,
              };
              final service = CalorieService();
              final logs = [
                for (var i = 0; i < 7; i++)
                  logsByDate[service.dateKey(
                        start.add(Duration(days: i)),
                      )] ??
                      DailyCalorieLog.empty(
                        service.dateKey(start.add(Duration(days: i))),
                      ),
              ];
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
                          BarChartRodData(
                              toY: goal.toDouble(),
                              width: 9,
                              color: Colors.grey),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
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
