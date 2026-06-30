import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nutri_tracker/database/user_model.dart';
import 'package:nutri_tracker/models/daily_health_summary.dart';
import 'package:nutri_tracker/models/meal_entry.dart';
import 'package:nutri_tracker/models/user_goal.dart';
import 'package:nutri_tracker/models/workout_session.dart';
import 'package:nutri_tracker/repositories/goal_repository.dart';
import 'package:nutri_tracker/repositories/workout_repository.dart';
import 'package:nutri_tracker/routes/app_routes.dart';
import 'package:nutri_tracker/services/calorie_service.dart';
import 'package:nutri_tracker/services/daily_summary_service.dart';
import 'package:nutri_tracker/services/firestore_service.dart';
import 'package:nutri_tracker/services/health_sync_service.dart';
import 'package:nutri_tracker/utils/health_utils.dart';
import 'package:nutri_tracker/widgets/water_tracker_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please sign in.')));
    }
    return StreamBuilder<UserModel>(
      stream: FirestoreService().watchUser(uid),
      builder: (context, userSnapshot) {
        final user = userSnapshot.data ?? UserModel();
        return StreamBuilder<UserGoal?>(
          stream: GoalRepository().watchActiveGoal(uid),
          builder: (context, goalSnapshot) {
            final goal = goalSnapshot.data;
            return StreamBuilder<DailyCalorieLog>(
              stream: CalorieService().watchDailyLog(uid, DateTime.now()),
              builder: (context, logSnapshot) {
                final log = logSnapshot.data ??
                    DailyCalorieLog.empty(
                        CalorieService().dateKey(DateTime.now()));
                return StreamBuilder<List<WorkoutSession>>(
                  stream: WorkoutRepository().watchTodaySessions(uid),
                  builder: (context, workoutSnapshot) {
                    final workouts =
                        workoutSnapshot.data ?? const <WorkoutSession>[];
                    return StreamBuilder<DailyHealthSummary>(
                      stream: DailySummaryService()
                          .watchSummary(uid, DateTime.now()),
                      builder: (context, summarySnapshot) {
                        return _DashboardBody(
                          uid: uid,
                          user: user,
                          goal: goal,
                          log: log,
                          summary: summarySnapshot.data,
                          workouts: workouts,
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.uid,
    required this.user,
    required this.goal,
    required this.log,
    required this.summary,
    required this.workouts,
  });

  final String uid;
  final UserModel user;
  final UserGoal? goal;
  final DailyCalorieLog log;
  final DailyHealthSummary? summary;
  final List<WorkoutSession> workouts;

  @override
  Widget build(BuildContext context) {
    final calorieGoal = goal?.dailyCalorieGoal ?? user.dailyCalorieGoal ?? 2000;
    final burned = log.caloriesBurned;
    final net = log.totalCalories - burned;
    final remaining = calorieGoal - net;
    final proteinGoal = goal?.proteinGoalG ?? 100;
    final waterGoal = goal?.waterGoalMl ?? 2500;
    final workoutMinutes = workouts.fold<int>(
      0,
      (total, session) => total + session.totalDurationMinutes,
    );
    final healthScore = _healthScore(
      calories: log.totalCalories,
      calorieGoal: calorieGoal,
      protein: log.totalProtein,
      proteinGoal: proteinGoal,
      water: log.waterIntakeMl,
      waterGoal: waterGoal,
      workoutMinutes: workoutMinutes,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('NutriTrack India'),
        actions: [
          IconButton(
            tooltip: 'Goals',
            onPressed: () => context.push(AppRoutes.goals),
            icon: const Icon(Icons.flag_outlined),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.push(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => HealthSyncService().syncToday(uid),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              'Good ${_greeting()}, ${user.name ?? 'there'}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(DateFormat('EEEE, d MMMM').format(DateTime.now())),
            const SizedBox(height: 16),
            _ScoreCard(score: healthScore),
            const SizedBox(height: 12),
            _CalorieCard(
              consumed: log.totalCalories,
              burned: burned,
              net: net,
              remaining: remaining,
              goal: calorieGoal,
            ),
            const SizedBox(height: 12),
            _ProgressGrid(
              protein: log.totalProtein,
              proteinGoal: proteinGoal,
              water: log.waterIntakeMl,
              waterGoal: waterGoal,
              stepsGoal: goal?.stepGoal ?? 8000,
              steps: summary?.steps ?? log.steps,
            ),
            const SizedBox(height: 12),
            _WorkoutTodayCard(
              workouts: workouts,
              caloriesBurned: burned,
              minutes: workoutMinutes,
            ),
            const SizedBox(height: 12),
            _QuickActions(uid: uid, log: log),
            const SizedBox(height: 12),
            _HealthSyncCard(uid: uid),
            const SizedBox(height: 12),
            _WeightStatus(user: user),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  int _healthScore({
    required int calories,
    required int calorieGoal,
    required double protein,
    required int proteinGoal,
    required int water,
    required int waterGoal,
    required int workoutMinutes,
  }) {
    final calorieScore =
        (1 - ((calories - calorieGoal).abs() / calorieGoal)).clamp(0.0, 1.0);
    final proteinScore = (protein / proteinGoal).clamp(0.0, 1.0);
    final waterScore = (water / waterGoal).clamp(0.0, 1.0);
    final workoutScore = (workoutMinutes / 30).clamp(0.0, 1.0);
    return ((calorieScore * 35) +
            (proteinScore * 25) +
            (waterScore * 20) +
            (workoutScore * 20))
        .round();
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 76,
              height: 76,
              child: CircularProgressIndicator(
                strokeWidth: 9,
                value: score / 100,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$score',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const Text('Daily health score'),
                ],
              ),
            ),
            const Icon(Icons.favorite_rounded),
          ],
        ),
      ),
    );
  }
}

class _CalorieCard extends StatelessWidget {
  const _CalorieCard({
    required this.consumed,
    required this.burned,
    required this.net,
    required this.remaining,
    required this.goal,
  });

  final int consumed;
  final int burned;
  final int net;
  final int remaining;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final percent = (consumed / goal).clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Calories', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: percent),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _Metric(label: 'Consumed', value: '$consumed kcal'),
                _Metric(label: 'Burned', value: '$burned kcal'),
                _Metric(label: 'Net', value: '$net kcal'),
                _Metric(label: 'Remaining', value: '$remaining kcal'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressGrid extends StatelessWidget {
  const _ProgressGrid({
    required this.protein,
    required this.proteinGoal,
    required this.water,
    required this.waterGoal,
    required this.stepsGoal,
    required this.steps,
  });

  final double protein;
  final int proteinGoal;
  final int water;
  final int waterGoal;
  final int stepsGoal;
  final int steps;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;
        return GridView.count(
          crossAxisCount: compact ? 2 : 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: compact ? 1.35 : 1.55,
          children: [
            _SmallProgressCard(
              icon: Icons.egg_alt_outlined,
              label: 'Protein',
              value: '${protein.toStringAsFixed(0)}g',
              progress: protein / proteinGoal,
            ),
            _SmallProgressCard(
              icon: Icons.water_drop_outlined,
              label: 'Water',
              value: '${water}ml',
              progress: water / waterGoal,
            ),
            _SmallProgressCard(
              icon: Icons.directions_walk_outlined,
              label: 'Steps',
              value: '$steps',
              progress: steps / stepsGoal,
              footer: '$stepsGoal goal',
            ),
            _SmallProgressCard(
              icon: Icons.flag_outlined,
              label: 'Goal',
              value: '$proteinGoal g',
              progress: 1,
              footer: 'protein target',
            ),
          ],
        );
      },
    );
  }
}

class _WorkoutTodayCard extends StatelessWidget {
  const _WorkoutTodayCard({
    required this.workouts,
    required this.caloriesBurned,
    required this.minutes,
  });

  final List<WorkoutSession> workouts;
  final int caloriesBurned;
  final int minutes;

  @override
  Widget build(BuildContext context) {
    final latest = workouts.isEmpty ? null : workouts.first;
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.fitness_center)),
        title: Text(latest?.title ?? "Today's workout"),
        subtitle: Text('$minutes min trained - $caloriesBurned kcal burned'),
        trailing: FilledButton(
          onPressed: () => context.push(AppRoutes.activeWorkoutSession),
          child: const Text('Start'),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.uid, required this.log});

  final String uid;
  final DailyCalorieLog log;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ActionButton(
              icon: Icons.add,
              label: 'Log meal',
              onTap: () => context.push(AppRoutes.nutritionAdd),
            ),
            _ActionButton(
              icon: Icons.qr_code_scanner,
              label: 'Scan food',
              onTap: () => context.push(AppRoutes.nutritionAdd),
            ),
            _ActionButton(
              icon: Icons.fitness_center,
              label: 'Start workout',
              onTap: () => context.push(AppRoutes.activeWorkoutSession),
            ),
            _ActionButton(
              icon: Icons.water_drop,
              label: 'Log water',
              onTap: () => showModalBottomSheet<void>(
                context: context,
                builder: (_) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: WaterTrackerWidget(
                    uid: uid,
                    date: DateTime.now(),
                    waterIntakeMl: log.waterIntakeMl,
                  ),
                ),
              ),
            ),
            _ActionButton(
              icon: Icons.monitor_weight,
              label: 'Weigh in',
              onTap: () => context.push(AppRoutes.bmiCalculator),
            ),
            _ActionButton(
              icon: Icons.auto_awesome,
              label: 'Ask Coach',
              onTap: () => context.push(AppRoutes.aiChat),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthSyncCard extends StatefulWidget {
  const _HealthSyncCard({required this.uid});

  final String uid;

  @override
  State<_HealthSyncCard> createState() => _HealthSyncCardState();
}

class _HealthSyncCardState extends State<_HealthSyncCard> {
  late Future<HealthSyncSnapshot> _syncFuture;

  @override
  void initState() {
    super.initState();
    _syncFuture = HealthSyncService().syncToday(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HealthSyncSnapshot>(
      future: _syncFuture,
      builder: (context, snapshot) {
        final data = snapshot.data;
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Icon(
                data?.permissionDenied == true
                    ? Icons.health_and_safety_outlined
                    : Icons.sync,
              ),
            ),
            title: const Text('Health sync'),
            subtitle: Text(data?.message ?? 'Checking Health permissions...'),
            trailing: Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('${data?.steps ?? 0} steps'),
                IconButton(
                  tooltip: 'Sync now',
                  onPressed: _sync,
                  icon: const Icon(Icons.sync),
                ),
                IconButton(
                  tooltip: 'Manual fallback',
                  onPressed: _manualFallback,
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _sync() {
    setState(() {
      _syncFuture = HealthSyncService().syncToday(widget.uid);
    });
  }

  Future<void> _manualFallback() async {
    final steps = TextEditingController();
    final calories = TextEditingController();
    final result = await showDialog<(int, int)>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manual health data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: steps,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Steps'),
            ),
            TextField(
              controller: calories,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Active calories'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              (
                int.tryParse(steps.text.trim()) ?? 0,
                int.tryParse(calories.text.trim()) ?? 0,
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    steps.dispose();
    calories.dispose();
    if (result == null) return;
    setState(() {
      _syncFuture = HealthSyncService().saveToday(
        uid: widget.uid,
        steps: result.$1,
        activeCalories: result.$2,
      );
    });
  }
}

class _WeightStatus extends StatelessWidget {
  const _WeightStatus({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final bmi = user.bmi ?? 0;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: getBmiColor(bmi).withOpacity(0.15),
          child: Icon(Icons.monitor_weight, color: getBmiColor(bmi)),
        ),
        title: Text('Weight/BMI status: ${getBmiCategory(bmi)}'),
        subtitle: Text(
          bmi <= 0
              ? 'Add your first BMI check.'
              : 'BMI ${bmi.toStringAsFixed(1)} - Weight ${user.weight ?? '--'} kg',
        ),
      ),
    );
  }
}

class _SmallProgressCard extends StatelessWidget {
  const _SmallProgressCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.progress,
    this.footer,
  });

  final IconData icon;
  final String label;
  final String value;
  final double progress;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const Spacer(),
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress.clamp(0.0, 1.0)),
            if (footer != null)
              Text(footer!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 135,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
