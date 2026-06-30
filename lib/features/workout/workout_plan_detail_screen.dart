import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/features/workout/workout_session_screen.dart';
import 'package:nutri_tracker/models/workout_plan.dart';

class WorkoutPlanDetailScreen extends StatelessWidget {
  const WorkoutPlanDetailScreen({super.key, required this.plan});

  final WorkoutPlan plan;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please sign in.')));
    }

    return Scaffold(
      appBar: AppBar(title: Text(plan.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.emoji, style: const TextStyle(fontSize: 48)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plan.description,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Chip(label: Text('${plan.durationMinutes} min')),
                            Chip(
                              label: Text('${plan.estimatedCalories} kcal'),
                            ),
                            Chip(label: Text(plan.difficulty)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Exercises', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final exercise in plan.exercises)
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(exercise.emoji)),
                title: Text(exercise.name),
                subtitle: Text(
                  '${_exerciseTarget(exercise)}  \u{2022}  Rest: ${exercise.restSeconds}s\n'
                  '${exercise.instructions}',
                ),
                isThreeLine: true,
              ),
            ),
          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Workout'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WorkoutSessionScreen(plan: plan),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _exerciseTarget(WorkoutExercise exercise) {
    if (exercise.reps > 0) {
      return '${exercise.sets} sets x ${exercise.reps} reps';
    }
    return '${exercise.sets} sets x ${exercise.durationSeconds}s';
  }
}
