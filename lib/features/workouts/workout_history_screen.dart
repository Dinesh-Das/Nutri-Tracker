import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutri_tracker/models/workout_session.dart';
import 'package:nutri_tracker/repositories/workout_repository.dart';

class WorkoutHistoryScreen extends StatelessWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please sign in.')));
    }
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(title: const Text('Workout history')),
      body: FutureBuilder<List<WorkoutSession>>(
        future: WorkoutRepository().getSessionsInRange(
          uid,
          start: now.subtract(const Duration(days: 60)),
          end: now,
        ),
        builder: (context, snapshot) {
          final sessions = snapshot.data ?? const <WorkoutSession>[];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (sessions.isEmpty) {
            return const Center(child: Text('No completed workouts yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              final completed = session.exercises
                  .where((exercise) => exercise.completed)
                  .length;
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.history)),
                  title: Text(session.title),
                  subtitle: Text(
                    '${DateFormat('d MMM').format(session.date)} - '
                    '${session.totalDurationMinutes} min - '
                    '$completed/${session.exercises.length} exercises',
                  ),
                  trailing: Text('${session.caloriesBurned} kcal'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
