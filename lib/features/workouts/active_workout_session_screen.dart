import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_tracker/models/achievement.dart';
import 'package:nutri_tracker/models/exercise.dart';
import 'package:nutri_tracker/models/workout_program.dart';
import 'package:nutri_tracker/models/workout_session.dart';
import 'package:nutri_tracker/repositories/workout_repository.dart';
import 'package:nutri_tracker/routes/app_routes.dart';
import 'package:nutri_tracker/services/achievement_service.dart';
import 'package:nutri_tracker/utils/health_utils.dart';

class ActiveWorkoutSessionScreen extends StatefulWidget {
  const ActiveWorkoutSessionScreen({super.key, this.seed});

  final Object? seed;

  @override
  State<ActiveWorkoutSessionScreen> createState() =>
      _ActiveWorkoutSessionScreenState();
}

class _ActiveWorkoutSessionScreenState
    extends State<ActiveWorkoutSessionScreen> {
  final _repository = WorkoutRepository();
  Timer? _timer;
  Timer? _restTimer;
  String _title = 'Home workout';
  String? _programId;
  List<WorkoutExerciseLog> _logs = const [];
  int _index = 0;
  int _elapsedSeconds = 0;
  int _restSeconds = 0;
  bool _running = false;
  bool _loading = true;
  bool _saving = false;
  DateTime? _startedAt;

  @override
  void initState() {
    super.initState();
    _loadSeed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completed = _logs.where((log) => log.completed).length;
    final currentIndex =
        _logs.isEmpty ? 0 : _index.clamp(0, _logs.length - 1).toInt();
    final current = _logs.isEmpty ? null : _logs[currentIndex];
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? const Center(child: Text('No exercises available.'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Exercise ${currentIndex + 1} of ${_logs.length}',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              current?.name ?? '',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: completed / max(_logs.length, 1),
                            ),
                            const SizedBox(height: 12),
                            Text(_timerLabel(_elapsedSeconds)),
                          ],
                        ),
                      ),
                    ),
                    if (_restSeconds > 0)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.timer_outlined),
                          title: const Text('Rest timer'),
                          subtitle: LinearProgressIndicator(
                            value: 1 - (_restSeconds / 45).clamp(0.0, 1.0),
                          ),
                          trailing: Text('${_restSeconds}s'),
                        ),
                      ),
                    if (current != null) _ExerciseControls(log: current),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: _toggleTimer,
                          icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                          label: Text(_running ? 'Pause' : 'Start'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _completeCurrent,
                          icon: const Icon(Icons.check),
                          label: const Text('Complete'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _skipCurrent,
                          icon: const Icon(Icons.skip_next),
                          label: const Text('Skip'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _startRest,
                          icon: const Icon(Icons.timer),
                          label: const Text('Rest'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Column(
                        children: [
                          for (var i = 0; i < _logs.length; i++)
                            ListTile(
                              selected: i == _index,
                              leading: Icon(
                                _logs[i].completed
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                              ),
                              title: Text(_logs[i].name),
                              subtitle: Text(_exerciseSubtitle(_logs[i])),
                              onTap: () => setState(() => _index = i),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _saving ? null : _finish,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.flag),
                      label: const Text('Finish workout'),
                    ),
                  ],
                ),
    );
  }

  Future<void> _loadSeed() async {
    final exercises = await _repository.loadExercises();
    final seed = widget.seed;
    var selected = <Exercise>[];
    var title = 'Home workout';
    String? programId;
    if (seed is WorkoutProgram) {
      title = seed.title;
      programId = seed.id;
      final day = seed.workoutDays.isEmpty ? null : seed.workoutDays.first;
      final ids = day?.exerciseIds.toSet() ?? <String>{};
      selected =
          exercises.where((exercise) => ids.contains(exercise.id)).toList();
    } else if (seed is Exercise) {
      title = seed.name;
      selected = [seed];
    } else if (seed is WorkoutSession) {
      title = seed.title;
      programId = seed.programId;
      setState(() {
        _title = title;
        _programId = programId;
        _logs = seed.exercises;
        _loading = false;
      });
      return;
    }
    if (selected.isEmpty) {
      selected = exercises.take(5).toList();
    }
    setState(() {
      _title = title;
      _programId = programId;
      _logs = selected.map(_logFromExercise).toList();
      _loading = false;
    });
  }

  WorkoutExerciseLog _logFromExercise(Exercise exercise) {
    final durationSeconds = exercise.durationSeconds ??
        ((exercise.defaultSets ?? 3) * (exercise.defaultReps ?? 10) * 4);
    final calories = estimateExerciseCalories(
      metValue: exercise.metValue,
      durationMinutes: max(1, (durationSeconds / 60).round()),
      weightKg: 70,
    );
    return WorkoutExerciseLog(
      exerciseId: exercise.id,
      name: exercise.name,
      sets: exercise.defaultSets,
      reps: exercise.defaultReps,
      durationSeconds: durationSeconds,
      restSeconds: 45,
      caloriesBurned: calories,
    );
  }

  void _toggleTimer() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
      return;
    }
    _startedAt ??= DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });
    setState(() => _running = true);
  }

  void _completeCurrent() {
    final updated = [..._logs];
    updated[_index] = updated[_index].copyWith(completed: true);
    setState(() {
      _logs = updated;
      if (_index < _logs.length - 1) _index++;
    });
    _startRest();
  }

  void _skipCurrent() {
    setState(() {
      if (_index < _logs.length - 1) {
        _index++;
      }
    });
  }

  void _startRest() {
    _restTimer?.cancel();
    setState(() => _restSeconds = 45);
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _restSeconds = 0);
        return;
      }
      if (mounted) setState(() => _restSeconds--);
    });
  }

  Future<void> _finish() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    _timer?.cancel();
    final completedLogs = _logs.where((log) => log.completed).toList();
    final logsToSave = completedLogs.isEmpty ? _logs : completedLogs;
    final calories = logsToSave.fold<int>(
      0,
      (total, log) => total + log.caloriesBurned,
    );
    final now = DateTime.now();
    final durationMinutes = max(1, (_elapsedSeconds / 60).round());
    try {
      await _repository.saveSession(
        WorkoutSession(
          id: '',
          uid: uid,
          programId: _programId,
          title: _title,
          date: now,
          dateKey: _repository.dateKey(now),
          startedAt: _startedAt ?? now,
          completedAt: now,
          status: 'completed',
          totalDurationMinutes: durationMinutes,
          caloriesBurned: calories,
          exercises: _logs,
          source: _programId == null ? 'manual' : 'program',
        ),
      );
      await AchievementService().checkAndAward(
        uid,
        AchievementType.firstWorkout,
      );
      if (mounted) context.go(AppRoutes.workoutHistory);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _timerLabel(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  String _exerciseSubtitle(WorkoutExerciseLog log) {
    if (log.reps != null) {
      return '${log.sets ?? 1} sets x ${log.reps} reps';
    }
    return '${log.durationSeconds ?? 0}s';
  }
}

class _ExerciseControls extends StatelessWidget {
  const _ExerciseControls({required this.log});

  final WorkoutExerciseLog log;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tracker', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _TrackerPill(
                  icon: Icons.repeat,
                  label: 'Sets',
                  value: '${log.sets ?? 1}',
                ),
                _TrackerPill(
                  icon: Icons.fitness_center,
                  label: 'Reps',
                  value: log.reps == null ? '-' : '${log.reps}',
                ),
                _TrackerPill(
                  icon: Icons.timer_outlined,
                  label: 'Duration',
                  value: '${log.durationSeconds ?? 0}s',
                ),
                _TrackerPill(
                  icon: Icons.local_fire_department_outlined,
                  label: 'Burn',
                  value: '${log.caloriesBurned} kcal',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackerPill extends StatelessWidget {
  const _TrackerPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text('$label: $value'),
    );
  }
}
