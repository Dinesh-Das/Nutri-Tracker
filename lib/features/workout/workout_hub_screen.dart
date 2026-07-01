import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_tracker/data/workout_library.dart';
import 'package:nutri_tracker/features/workout/home_workout_screen.dart';
import 'package:nutri_tracker/features/workout/workout_plan_detail_screen.dart';
import 'package:nutri_tracker/models/workout_entry.dart';
import 'package:nutri_tracker/models/workout_plan.dart';
import 'package:nutri_tracker/routes/app_routes.dart';
import 'package:nutri_tracker/services/workout_service.dart';

class WorkoutHubScreen extends StatelessWidget {
  const WorkoutHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please sign in.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Workouts')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Home Workouts',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: min(5, kWorkoutLibrary.length),
                itemBuilder: (context, index) {
                  final plan = kWorkoutLibrary[index];
                  return _PlanPreviewCard(plan: plan);
                },
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HomeWorkoutScreen(),
                ),
              ),
              icon: const Icon(Icons.grid_view),
              label: const Text('Browse All Workouts'),
            ),
            const SizedBox(height: 20),
            Text('Quick Log', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.add)),
                title: const Text('Log a workout manually'),
                subtitle: const Text('Running, cycling, gym, sports...'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.workoutLog),
              ),
            ),
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.restaurant)),
                title: const Text('Explore Indian recipes'),
                subtitle: const Text('Meal ideas to support your training'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.recipes),
              ),
            ),
            const SizedBox(height: 20),
            Text('Explore', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                    child: Icon(Icons.calendar_today_outlined)),
                title: const Text('Workout Programs'),
                subtitle: const Text(
                    '8 structured plans from beginner to advanced'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.workoutPrograms),
              ),
            ),
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                    child: Icon(Icons.menu_book_outlined)),
                title: const Text('Exercise Library'),
                subtitle:
                    const Text('20+ exercises with instructions & tips'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.workoutLibrary),
              ),
            ),
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                    child: Icon(Icons.history_outlined)),
                title: const Text('Workout History'),
                subtitle:
                    const Text('Past sessions, streaks, and calories'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.workoutHistory),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Today's Activity",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const _TodayWorkoutSummary(),
          ],
        ),
      ),
    );
  }
}

class _PlanPreviewCard extends StatelessWidget {
  const _PlanPreviewCard({required this.plan});

  final WorkoutPlan plan;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WorkoutPlanDetailScreen(plan: plan),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.emoji, style: const TextStyle(fontSize: 36)),
                const SizedBox(height: 8),
                Text(
                  plan.name,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Text(
                  '${plan.durationMinutes} min',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  plan.difficulty,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TodayWorkoutSummary extends StatelessWidget {
  const _TodayWorkoutSummary();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<List<ExerciseEntry>>(
      stream: WorkoutService().watchTodayWorkouts(uid),
      builder: (context, snapshot) {
        final workouts = snapshot.data ?? const <ExerciseEntry>[];
        final total = workouts.fold<int>(
          0,
          (sum, entry) => sum + entry.caloriesBurned,
        );
        if (workouts.isEmpty) {
          return const Card(
            child: ListTile(
              title: Text('No workouts yet today'),
              subtitle: Text('Tap a plan above to get started'),
            ),
          );
        }
        return Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${workouts.length} workout${workouts.length > 1 ? "s" : ""}',
                        ),
                        Text('$total kcal burned'),
                      ],
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
            for (final workout in workouts)
              Card(
                child: ListTile(
                  leading:
                      const CircleAvatar(child: Icon(Icons.fitness_center)),
                  title: Text(workout.name),
                  subtitle: Text('${workout.durationMinutes} min'),
                  trailing: Text('${workout.caloriesBurned} kcal'),
                ),
              ),
          ],
        );
      },
    );
  }
}
