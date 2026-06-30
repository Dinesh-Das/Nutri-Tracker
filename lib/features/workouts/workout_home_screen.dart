import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_tracker/models/user_workout_program.dart';
import 'package:nutri_tracker/models/workout_program.dart';
import 'package:nutri_tracker/models/workout_session.dart';
import 'package:nutri_tracker/repositories/workout_repository.dart';
import 'package:nutri_tracker/routes/app_routes.dart';

class WorkoutHomeScreen extends StatelessWidget {
  const WorkoutHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please sign in.')));
    }
    final repository = WorkoutRepository();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts'),
        actions: [
          IconButton(
            tooltip: 'Exercise library',
            onPressed: () => context.push(AppRoutes.workoutLibrary),
            icon: const Icon(Icons.view_list_outlined),
          ),
          IconButton(
            tooltip: 'History',
            onPressed: () => context.push(AppRoutes.workoutHistory),
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.workoutSession),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Start'),
      ),
      body: StreamBuilder<UserWorkoutProgram?>(
        stream: repository.watchActiveProgram(uid),
        builder: (context, enrollmentSnapshot) {
          final enrollment = enrollmentSnapshot.data;
          return StreamBuilder<List<WorkoutSession>>(
            stream: repository.watchTodaySessions(uid),
            builder: (context, todaySnapshot) {
              final today = todaySnapshot.data ?? const <WorkoutSession>[];
              final calories = today.fold<int>(
                0,
                (total, session) => total + session.caloriesBurned,
              );
              final minutes = today.fold<int>(
                0,
                (total, session) => total + session.totalDurationMinutes,
              );
              return FutureBuilder<List<WorkoutProgram>>(
                future: repository.loadAvailablePrograms(uid),
                builder: (context, programSnapshot) {
                  final programs =
                      programSnapshot.data ?? const <WorkoutProgram>[];
                  final activeProgram = enrollment == null
                      ? null
                      : programs.cast<WorkoutProgram?>().firstWhere(
                            (program) => program?.id == enrollment.programId,
                            orElse: () => null,
                          );
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    children: [
                      _TodayWorkoutCard(
                        session: today.isEmpty ? null : today.first,
                        calories: calories,
                        minutes: minutes,
                        program: activeProgram,
                        enrollment: enrollment,
                      ),
                      const SizedBox(height: 12),
                      _WeeklySchedule(
                        uid: uid,
                        program: activeProgram,
                        enrollment: enrollment,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _StreakCard(uid: uid)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _StatCard(
                              label: 'Today',
                              value: '$calories kcal',
                              icon: Icons.local_fire_department_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _StatCard(
                        label: 'Minutes trained this week',
                        value: '$minutes min today',
                        icon: Icons.timer_outlined,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Recommended programs',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.push(AppRoutes.workoutPrograms),
                            child: const Text('View all'),
                          ),
                        ],
                      ),
                      for (final program in programs.take(4))
                        _ProgramTile(program: program),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => context.push(AppRoutes.workoutLog),
                        icon: const Icon(Icons.edit_note),
                        label: const Text('Manual workout log'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _TodayWorkoutCard extends StatelessWidget {
  const _TodayWorkoutCard({
    required this.session,
    required this.calories,
    required this.minutes,
    required this.program,
    required this.enrollment,
  });

  final WorkoutSession? session;
  final int calories;
  final int minutes;
  final WorkoutProgram? program;
  final UserWorkoutProgram? enrollment;

  @override
  Widget build(BuildContext context) {
    final plannedDay = _currentProgramDay(program, enrollment);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(child: Icon(Icons.fitness_center)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plannedDay?.title ??
                        session?.title ??
                        "Today's planned workout",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    program == null
                        ? '$minutes min - $calories kcal burned'
                        : 'Week ${enrollment?.currentWeek ?? 1}, day ${plannedDay?.day ?? enrollment?.currentDay ?? 1}',
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: () => context.push(
                AppRoutes.workoutSession,
                extra: program == null || enrollment == null
                    ? null
                    : WorkoutProgramSessionSeed(
                        program: program!,
                        enrollment: enrollment!,
                      ),
              ),
              icon: const Icon(Icons.play_arrow),
              label: Text(program == null ? 'Start' : 'Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklySchedule extends StatelessWidget {
  const _WeeklySchedule({
    required this.uid,
    required this.program,
    required this.enrollment,
  });

  final String uid;
  final WorkoutProgram? program;
  final UserWorkoutProgram? enrollment;

  @override
  Widget build(BuildContext context) {
    final days = program?.workoutDays.map((day) => day.day).toSet() ?? {};
    final totalSessions = (program?.durationWeeks ?? 0) * days.length;
    final completed = enrollment?.completedSessionIds.length ?? 0;
    final progress = totalSessions == 0 ? 0.0 : completed / totalSessions;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly schedule',
                style: Theme.of(context).textTheme.titleMedium),
            if (program != null) ...[
              const SizedBox(height: 4),
              Text(program!.title),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: progress.clamp(0.0, 1.0)),
              const SizedBox(height: 4),
              Text('$completed / $totalSessions sessions complete'),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (var day = 1; day <= 7; day++)
                  Chip(
                    backgroundColor: days.contains(day)
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    label: Text('D$day'),
                  ),
              ],
            ),
            if (program != null && enrollment != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  await WorkoutRepository().skipCurrentProgramDay(
                    uid,
                    program!,
                    enrollment!,
                  );
                },
                icon: const Icon(Icons.skip_next),
                label: const Text('Skip current day'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

WorkoutProgramDay? _currentProgramDay(
  WorkoutProgram? program,
  UserWorkoutProgram? enrollment,
) {
  if (program == null || enrollment == null || program.workoutDays.isEmpty) {
    return null;
  }
  final days = [...program.workoutDays]..sort((a, b) => a.day.compareTo(b.day));
  return days.firstWhere(
    (day) => day.day == enrollment.currentDay,
    orElse: () => days.first,
  );
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: WorkoutRepository().getWorkoutStreak(uid),
      builder: (context, snapshot) {
        return _StatCard(
          label: 'Workout streak',
          value: '${snapshot.data ?? 0} days',
          icon: Icons.bolt_outlined,
        );
      },
    );
  }
}

class _ProgramTile extends StatelessWidget {
  const _ProgramTile({required this.program});

  final WorkoutProgram program;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.assignment_outlined)),
        title: Text(program.title),
        subtitle: Text(
          '${program.level} - ${program.daysPerWeek} days/week - ${program.equipment}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(AppRoutes.workoutDetail, extra: program),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: Theme.of(context).textTheme.titleMedium),
                  Text(label),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
