import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_tracker/models/workout_program.dart';
import 'package:nutri_tracker/repositories/workout_repository.dart';
import 'package:nutri_tracker/routes/app_routes.dart';

class WorkoutProgramListScreen extends StatelessWidget {
  const WorkoutProgramListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please sign in.')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Workout programs')),
      body: FutureBuilder<List<WorkoutProgram>>(
        future: WorkoutRepository().loadAvailablePrograms(uid),
        builder: (context, snapshot) {
          final programs = snapshot.data ?? const <WorkoutProgram>[];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: programs.length,
            itemBuilder: (context, index) {
              final program = programs[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.assignment)),
                  title: Text(program.title),
                  subtitle: Text(program.description),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      context.push(AppRoutes.workoutDetail, extra: program),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
