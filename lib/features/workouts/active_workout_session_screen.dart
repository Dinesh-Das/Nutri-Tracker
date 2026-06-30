import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_tracker/models/achievement.dart';
import 'package:nutri_tracker/models/exercise.dart';
import 'package:nutri_tracker/models/user_workout_program.dart';
import 'package:nutri_tracker/models/workout_program.dart';
import 'package:nutri_tracker/models/workout_session.dart';
import 'package:nutri_tracker/repositories/workout_repository.dart';
import 'package:nutri_tracker/routes/app_routes.dart';
import 'package:nutri_tracker/services/achievement_service.dart';
import 'package:nutri_tracker/services/daily_summary_service.dart';
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
  WorkoutProgram? _program;
  UserWorkoutProgram? _enrollment;
  List<WorkoutExerciseLog> _logs = const [];
  final Map<String, double> _metByExerciseId = {};
  int _index = 0;
  int _elapsedSeconds = 0;
  int _restSeconds = 0;
  int _restTotalSeconds = 0;
  double _weightKg = 70;
  bool _running = false;
  bool _loading = true;
  bool _saving = false;
  bool _allowPop = false;
  bool _dirty = false;
  DateTime? _startedAt;

  bool get _hasActiveUnsavedWork {
    if (_loading || _saving || _allowPop) return false;
    return _running ||
        _elapsedSeconds > 0 ||
        _dirty ||
        _logs.any((log) => log.completed || log.completedSets.contains(true));
  }

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
    return PopScope<void>(
      canPop: !_hasActiveUnsavedWork,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _hasActiveUnsavedWork) _confirmExit();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_title),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                avatar: Icon(
                  _running ? Icons.play_arrow : Icons.pause,
                  size: 18,
                ),
                label: Text(_running ? 'Running' : 'Paused'),
              ),
            ),
          ],
        ),
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
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: completed / max(_logs.length, 1),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Chip(
                                    avatar: const Icon(Icons.timer_outlined),
                                    label: Text(_timerLabel(_elapsedSeconds)),
                                  ),
                                  Chip(
                                    avatar: const Icon(Icons.monitor_weight),
                                    label: Text(
                                      '${_weightKg.toStringAsFixed(1)} kg',
                                    ),
                                  ),
                                  if (_program != null && _enrollment != null)
                                    Chip(
                                      avatar: const Icon(Icons.flag_outlined),
                                      label: Text(
                                        'Week ${_enrollment!.currentWeek}, day ${_enrollment!.currentDay}',
                                      ),
                                    ),
                                ],
                              ),
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
                              value: _restTotalSeconds == 0
                                  ? 0
                                  : 1 - (_restSeconds / _restTotalSeconds),
                            ),
                            trailing: Text('${_restSeconds}s'),
                          ),
                        ),
                      if (current != null)
                        _ExerciseControls(
                          log: current,
                          onChanged: (log) => _replaceCurrent(log),
                          onToggleSet: _toggleCurrentSet,
                        ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.icon(
                            onPressed: _toggleTimer,
                            icon: Icon(
                              _running ? Icons.pause : Icons.play_arrow,
                            ),
                            label: Text(_running ? 'Pause' : 'Resume'),
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
                            onPressed: current == null
                                ? null
                                : () => _startRest(current.restSeconds),
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
                                trailing:
                                    Text('${_logs[i].caloriesBurned} kcal'),
                                onTap: () => setState(() => _index = i),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _saving ? null : _showSummaryAndSave,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.flag),
                        label: const Text('Finish workout'),
                      ),
                    ],
                  ),
      ),
    );
  }

  Future<void> _loadSeed() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final exercises = await _repository.loadExercises();
    _weightKg = uid == null ? 70 : await _loadUserWeight(uid);
    _metByExerciseId
      ..clear()
      ..addEntries(exercises.map((exercise) {
        return MapEntry(exercise.id, exercise.metValue);
      }));

    final seed = widget.seed;
    var selected = <Exercise>[];
    var title = 'Home workout';
    String? programId;
    if (seed is WorkoutProgramSessionSeed) {
      final day = _programDay(seed.program, seed.enrollment.currentDay);
      title = '${seed.program.title}: ${day?.title ?? 'Workout'}';
      programId = seed.program.id;
      _program = seed.program;
      _enrollment = seed.enrollment;
      selected = _exercisesForDay(exercises, day);
    } else if (seed is WorkoutProgram) {
      final day = seed.workoutDays.isEmpty ? null : seed.workoutDays.first;
      title = '${seed.title}: ${day?.title ?? 'Workout'}';
      programId = seed.id;
      _program = seed;
      selected = _exercisesForDay(exercises, day);
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
        _startedAt = seed.startedAt;
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

  Future<double> _loadUserWeight(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('user_details')
        .doc(uid)
        .get();
    final value = doc.data()?['weight'];
    if (value is num && value > 0) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null && parsed > 0) return parsed;
    }
    return 70;
  }

  WorkoutProgramDay? _programDay(WorkoutProgram program, int dayNumber) {
    if (program.workoutDays.isEmpty) return null;
    final days = [...program.workoutDays]
      ..sort((a, b) => a.day.compareTo(b.day));
    return days.firstWhere(
      (day) => day.day == dayNumber,
      orElse: () => days.first,
    );
  }

  List<Exercise> _exercisesForDay(
    List<Exercise> exercises,
    WorkoutProgramDay? day,
  ) {
    final byId = {for (final exercise in exercises) exercise.id: exercise};
    return [
      for (final id in day?.exerciseIds ?? const <String>[])
        if (byId[id] != null) byId[id]!,
    ];
  }

  WorkoutExerciseLog _logFromExercise(Exercise exercise) {
    final durationSeconds = exercise.durationSeconds ??
        ((exercise.defaultSets ?? 3) * (exercise.defaultReps ?? 10) * 4);
    final sets = exercise.defaultSets;
    final calories = estimateExerciseCalories(
      metValue: exercise.metValue,
      durationMinutes: max(1, (durationSeconds / 60).round()),
      weightKg: _weightKg,
    );
    return WorkoutExerciseLog(
      exerciseId: exercise.id,
      name: exercise.name,
      sets: sets,
      reps: exercise.defaultReps,
      durationSeconds: durationSeconds,
      restSeconds: 45,
      completedSets:
          sets == null ? const [] : List<bool>.filled(sets.clamp(0, 50), false),
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

  void _replaceCurrent(WorkoutExerciseLog log) {
    final updated = [..._logs];
    updated[_index] = _recalculateLog(log);
    setState(() {
      _logs = updated;
      _dirty = true;
    });
  }

  void _toggleCurrentSet(int setIndex, bool completed) {
    final current = _logs[_index];
    final sets = [...current.completedSets];
    if (setIndex < 0 || setIndex >= sets.length) return;
    sets[setIndex] = completed;
    final allDone = sets.isNotEmpty && sets.every((value) => value);
    _replaceCurrent(current.copyWith(
      completedSets: sets,
      completed: allDone,
    ));
  }

  WorkoutExerciseLog _recalculateLog(WorkoutExerciseLog log) {
    final met = _metByExerciseId[log.exerciseId] ?? 5.0;
    final durationSeconds = log.durationSeconds ?? 60;
    final calories = estimateExerciseCalories(
      metValue: met,
      durationMinutes: max(1, (durationSeconds / 60).round()),
      weightKg: _weightKg,
    );
    return log.copyWith(caloriesBurned: calories);
  }

  void _completeCurrent() {
    final current = _logs[_index];
    final completedSets = current.completedSets.isEmpty
        ? current.completedSets
        : List<bool>.filled(current.completedSets.length, true);
    _replaceCurrent(
      current.copyWith(completed: true, completedSets: completedSets),
    );
    _startRest(current.restSeconds);
    setState(() {
      if (_index < _logs.length - 1) _index++;
    });
  }

  void _skipCurrent() {
    setState(() {
      _dirty = true;
      if (_index < _logs.length - 1) _index++;
    });
  }

  void _startRest(int seconds) {
    _restTimer?.cancel();
    setState(() {
      _restSeconds = seconds.clamp(0, 600);
      _restTotalSeconds = _restSeconds;
    });
    if (_restSeconds <= 0) return;
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _restSeconds = 0);
        return;
      }
      if (mounted) setState(() => _restSeconds--);
    });
  }

  Future<void> _showSummaryAndSave() async {
    if (_saving) return;
    final completedLogs = _logs.where((log) => log.completed).toList();
    if (completedLogs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete at least one exercise.')),
      );
      return;
    }
    _timer?.cancel();
    _restTimer?.cancel();
    setState(() => _running = false);
    final calories = completedLogs.fold<int>(
      0,
      (total, log) => total + log.caloriesBurned,
    );
    final durationMinutes = _durationMinutes(completedLogs);
    final skipped = _logs.length - completedLogs.length;
    final save = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Workout summary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Exercises completed: ${completedLogs.length}'),
            Text('Skipped exercises: $skipped'),
            Text('Duration: $durationMinutes min'),
            Text('Calories: $calories kcal'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save workout'),
          ),
        ],
      ),
    );
    if (save == true)
      await _saveFinal(completedLogs, durationMinutes, calories);
  }

  int _durationMinutes(List<WorkoutExerciseLog> completedLogs) {
    if (_elapsedSeconds > 0) return max(1, (_elapsedSeconds / 60).round());
    final plannedSeconds = completedLogs.fold<int>(
      0,
      (total, log) => total + (log.durationSeconds ?? 0),
    );
    return max(1, (plannedSeconds / 60).round());
  }

  Future<void> _saveFinal(
    List<WorkoutExerciseLog> completedLogs,
    int durationMinutes,
    int calories,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _saving) return;
    setState(() => _saving = true);
    final now = DateTime.now();
    try {
      final saved = await _repository.saveSession(
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
      if (_program != null && _enrollment != null) {
        _enrollment = await _repository.completeProgramSession(
          uid: uid,
          program: _program!,
          enrollment: _enrollment!,
          sessionId: saved.id,
        );
      }
      await DailySummaryService().rebuildSummary(uid, now);
      await AchievementService().checkAndAward(
        uid,
        AchievementType.firstWorkout,
      );
      if (!mounted) return;
      _allowPop = true;
      context.go(AppRoutes.workoutHistory);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmExit() async {
    final exit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard active workout?'),
        content: const Text('Your current session has not been saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (exit == true && mounted) {
      setState(() => _allowPop = true);
      context.pop();
    }
  }

  String _timerLabel(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  String _exerciseSubtitle(WorkoutExerciseLog log) {
    if (log.reps != null) {
      return '${log.sets ?? 1} sets x ${log.reps} reps - rest ${log.restSeconds}s';
    }
    return '${log.durationSeconds ?? 0}s - rest ${log.restSeconds}s';
  }
}

class _ExerciseControls extends StatelessWidget {
  const _ExerciseControls({
    required this.log,
    required this.onChanged,
    required this.onToggleSet,
  });

  final WorkoutExerciseLog log;
  final ValueChanged<WorkoutExerciseLog> onChanged;
  final void Function(int setIndex, bool completed) onToggleSet;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tracker', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _NumberStepper(
                  icon: Icons.repeat,
                  label: 'Sets',
                  value: log.sets ?? 1,
                  min: 1,
                  max: 10,
                  onChanged: (value) {
                    final current = log.completedSets;
                    final nextSets = List<bool>.generate(
                      value,
                      (index) => index < current.length && current[index],
                    );
                    onChanged(log.copyWith(
                      sets: value,
                      completedSets: nextSets,
                      completed:
                          nextSets.isNotEmpty && nextSets.every((set) => set),
                    ));
                  },
                ),
                _NumberStepper(
                  icon: Icons.fitness_center,
                  label: 'Reps',
                  value: log.reps ?? 10,
                  min: 1,
                  max: 50,
                  onChanged: (value) => onChanged(log.copyWith(reps: value)),
                ),
                _NumberStepper(
                  icon: Icons.timer_outlined,
                  label: 'Duration sec',
                  value: log.durationSeconds ?? 60,
                  min: 10,
                  max: 1800,
                  step: 10,
                  onChanged: (value) =>
                      onChanged(log.copyWith(durationSeconds: value)),
                ),
                _NumberStepper(
                  icon: Icons.hourglass_bottom,
                  label: 'Rest sec',
                  value: log.restSeconds,
                  min: 0,
                  max: 300,
                  step: 5,
                  onChanged: (value) =>
                      onChanged(log.copyWith(restSeconds: value)),
                ),
              ],
            ),
            if (log.completedSets.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (var i = 0; i < log.completedSets.length; i++)
                    FilterChip(
                      selected: log.completedSets[i],
                      label: Text('Set ${i + 1}'),
                      onSelected: (selected) => onToggleSet(i, selected),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Chip(
              avatar: const Icon(Icons.local_fire_department_outlined),
              label: Text('Burn: ${log.caloriesBurned} kcal'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberStepper extends StatelessWidget {
  const _NumberStepper({
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.step = 1,
  });

  final IconData icon;
  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                Text('$value', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Decrease $label',
            onPressed: value <= min
                ? null
                : () => onChanged((value - step).clamp(min, max)),
            icon: const Icon(Icons.remove_circle_outline),
          ),
          IconButton(
            tooltip: 'Increase $label',
            onPressed: value >= max
                ? null
                : () => onChanged((value + step).clamp(min, max)),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
}
