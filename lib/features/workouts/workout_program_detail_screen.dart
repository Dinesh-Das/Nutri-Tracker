import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_tracker/models/workout_program.dart';
import 'package:nutri_tracker/routes/app_routes.dart';

class WorkoutProgramDetailScreen extends StatelessWidget {
  const WorkoutProgramDetailScreen({super.key, required this.program});

  final WorkoutProgram program;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(program.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(program.description),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text(program.level)),
                      Chip(label: Text(program.equipment)),
                      Chip(label: Text('${program.durationWeeks} weeks')),
                      Chip(label: Text('${program.daysPerWeek} days/week')),
                      Chip(
                          label: Text(
                              '${program.estimatedMinutesPerDay} min/day')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Workout days', style: Theme.of(context).textTheme.titleLarge),
          for (final day in program.workoutDays)
            Card(
              child: ListTile(
                title: Text('Day ${day.day}: ${day.title}'),
                subtitle: Text('${day.exerciseIds.length} exercises'),
              ),
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () =>
                context.push(AppRoutes.workoutSession, extra: program),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start program workout'),
          ),
        ],
      ),
    );
  }
}
