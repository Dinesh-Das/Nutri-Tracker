import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nutri_tracker/models/workout_entry.dart';
import 'package:nutri_tracker/services/firestore_service.dart';
import 'package:nutri_tracker/services/workout_service.dart';
import 'package:nutri_tracker/utils/health_utils.dart';

class WorkoutLogScreen extends StatefulWidget {
  const WorkoutLogScreen({super.key});

  @override
  State<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  final _service = WorkoutService();
  late final Future<List<ExerciseOption>> _exerciseOptionsFuture;

  @override
  void initState() {
    super.initState();
    _exerciseOptionsFuture = _loadExerciseOptions();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please sign in.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Log')),
      floatingActionButton: FutureBuilder<List<ExerciseOption>>(
        future: _exerciseOptionsFuture,
        builder: (context, optionsSnapshot) {
          return FloatingActionButton.extended(
            onPressed: optionsSnapshot.hasData
                ? () => _openQuickLog(uid, optionsSnapshot.data!)
                : null,
            icon: const Icon(Icons.add),
            label: const Text('Log workout'),
          );
        },
      ),
      body: FutureBuilder<double>(
        future: _currentWeightKg(uid),
        builder: (context, weightSnapshot) {
          final weightKg = weightSnapshot.data ?? 70;
          return StreamBuilder<List<ExerciseEntry>>(
            stream: _service.watchTodayWorkouts(uid),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Unable to load workouts: ${snapshot.error}'),
                );
              }
              final workouts = snapshot.data ?? const <ExerciseEntry>[];
              final totalDuration = workouts.fold<int>(
                0,
                (total, entry) => total + entry.durationMinutes,
              );
              final totalCalories = workouts.fold<int>(
                0,
                (total, entry) => total + entry.caloriesBurned,
              );

              return FutureBuilder<List<ExerciseOption>>(
                future: _exerciseOptionsFuture,
                builder: (context, optionsSnapshot) {
                  final options =
                      optionsSnapshot.data ?? defaultExerciseOptions;
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _WorkoutSummaryCard(
                        totalDuration: totalDuration,
                        totalCalories: totalCalories,
                        onQuickLog: () => _openQuickLog(uid, options),
                      ),
                      const SizedBox(height: 12),
                      if (workouts.isEmpty)
                        _WorkoutEmptyState(
                            onTap: () => _openQuickLog(uid, options))
                      else
                        for (final workout in workouts)
                          _WorkoutTile(entry: workout),
                      const SizedBox(height: 80),
                      Text(
                        'Estimates use MET values and your current weight (${weightKg.toStringAsFixed(0)} kg).',
                        style: Theme.of(context).textTheme.bodySmall,
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

  Future<double> _currentWeightKg(String uid) async {
    final user = await FirestoreService().getUser(uid);
    return double.tryParse(user.weight ?? '') ?? 70;
  }

  Future<List<ExerciseOption>> _loadExerciseOptions() async {
    final box = await Hive.openBox('exercise_options');
    if (box.isEmpty) {
      await box.putAll({
        for (final option in defaultExerciseOptions) option.key: option.toMap(),
      });
    }
    return box.values
        .whereType<Map>()
        .map(
            (value) => ExerciseOption.fromMap(Map<String, dynamic>.from(value)))
        .where((option) => option.name.isNotEmpty)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> _openQuickLog(
    String uid,
    List<ExerciseOption> options,
  ) async {
    final weightKg = await _currentWeightKg(uid);
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _QuickLogWorkoutSheet(
        uid: uid,
        options: options,
        weightKg: weightKg,
      ),
    );
  }
}

class _WorkoutSummaryCard extends StatelessWidget {
  const _WorkoutSummaryCard({
    required this.totalDuration,
    required this.totalCalories,
    required this.onQuickLog,
  });

  final int totalDuration;
  final int totalCalories;
  final VoidCallback onQuickLog;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Today's Workout",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('$totalDuration min'),
                  Text('$totalCalories kcal burned'),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: onQuickLog,
              icon: const Icon(Icons.fitness_center),
              label: const Text('Quick log'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutEmptyState extends StatelessWidget {
  const _WorkoutEmptyState({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.directions_run, size: 48),
            const SizedBox(height: 12),
            Text('No workouts logged today',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onTap,
              child: const Text('Log first workout'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutTile extends StatelessWidget {
  const _WorkoutTile({required this.entry});

  final ExerciseEntry entry;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.jm().format(entry.timestamp);
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.fitness_center)),
        title: Text(entry.name),
        subtitle: Text('${entry.durationMinutes} min - $time'),
        trailing: Text('${entry.caloriesBurned} kcal'),
      ),
    );
  }
}

class _QuickLogWorkoutSheet extends StatefulWidget {
  const _QuickLogWorkoutSheet({
    required this.uid,
    required this.options,
    required this.weightKg,
  });

  final String uid;
  final List<ExerciseOption> options;
  final double weightKg;

  @override
  State<_QuickLogWorkoutSheet> createState() => _QuickLogWorkoutSheetState();
}

class _QuickLogWorkoutSheetState extends State<_QuickLogWorkoutSheet> {
  final _service = WorkoutService();
  final _notesController = TextEditingController();
  Timer? _timer;
  late ExerciseOption _selected;
  int _duration = 30;
  int _sets = 3;
  int _reps = 10;
  int _remainingSeconds = 0;
  bool _saving = false;

  bool get _isStrength => _selected.category == 'strength';

  int get _estimatedCalories => estimateCaloriesBurned(
        exercise: _selected.key,
        durationMinutes: _duration,
        weightKg: widget.weightKg,
      );

  @override
  void initState() {
    super.initState();
    _selected = widget.options.first;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, inset + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick log workout',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Autocomplete<ExerciseOption>(
              initialValue: TextEditingValue(text: _selected.name),
              displayStringForOption: (option) => option.name,
              optionsBuilder: (value) {
                final query = value.text.toLowerCase().trim();
                if (query.isEmpty) return widget.options;
                return widget.options.where(
                  (option) => option.name.toLowerCase().contains(query),
                );
              },
              onSelected: (option) => setState(() => _selected = option),
            ),
            const SizedBox(height: 16),
            Text('Duration: $_duration minutes'),
            Slider(
              value: _duration.toDouble(),
              min: 5,
              max: 180,
              divisions: 35,
              label: '$_duration min',
              onChanged: (value) => setState(() => _duration = value.round()),
            ),
            if (_isStrength) ...[
              Row(
                children: [
                  Expanded(
                    child: _NumberStepper(
                      label: 'Sets',
                      value: _sets,
                      onChanged: (value) => setState(() => _sets = value),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NumberStepper(
                      label: 'Reps',
                      value: _reps,
                      onChanged: (value) => setState(() => _reps = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  const CircleAvatar(child: Icon(Icons.local_fire_department)),
              title: const Text('Estimated calories'),
              trailing: Text('$_estimatedCalories kcal'),
            ),
            if (_remainingSeconds > 0)
              LinearProgressIndicator(
                value: 1 - (_remainingSeconds / (_duration * 60)),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _timer == null ? _startTimer : null,
                    icon: const Icon(Icons.timer),
                    label: Text(
                        _remainingSeconds > 0 ? _timerLabel : 'Start Timer'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String get _timerLabel {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _startTimer() {
    setState(() => _remainingSeconds = _duration * 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        _timer = null;
        _save();
        return;
      }
      if (mounted) {
        setState(() => _remainingSeconds--);
      }
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final entry = ExerciseEntry(
      id: '',
      name: _selected.name,
      category: _selected.category,
      durationMinutes: _duration,
      caloriesBurned: _estimatedCalories,
      timestamp: DateTime.now(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      sets: _isStrength ? _sets : null,
      reps: _isStrength ? _reps : null,
    );
    try {
      await _service.logWorkout(widget.uid, entry);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _NumberStepper extends StatelessWidget {
  const _NumberStepper({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Decrease $label',
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove),
          ),
          Expanded(child: Center(child: Text('$value'))),
          IconButton(
            tooltip: 'Increase $label',
            onPressed: () => onChanged(value + 1),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

const defaultExerciseOptions = [
  ExerciseOption(name: 'Running', key: 'running', category: 'cardio'),
  ExerciseOption(name: 'Walking', key: 'walking', category: 'cardio'),
  ExerciseOption(name: 'Cycling', key: 'cycling', category: 'cardio'),
  ExerciseOption(name: 'Swimming', key: 'swimming', category: 'cardio'),
  ExerciseOption(name: 'Yoga', key: 'yoga', category: 'flexibility'),
  ExerciseOption(
      name: 'Strength Training',
      key: 'strength_training',
      category: 'strength'),
  ExerciseOption(name: 'HIIT', key: 'hiit', category: 'cardio'),
  ExerciseOption(name: 'Cricket', key: 'cricket', category: 'sports'),
  ExerciseOption(name: 'Football', key: 'football', category: 'sports'),
  ExerciseOption(name: 'Badminton', key: 'badminton', category: 'sports'),
  ExerciseOption(name: 'Kabaddi', key: 'kabaddi', category: 'sports'),
  ExerciseOption(name: 'Dance', key: 'dance', category: 'cardio'),
  ExerciseOption(name: 'Pilates', key: 'pilates', category: 'flexibility'),
  ExerciseOption(name: 'Rowing', key: 'rowing', category: 'cardio'),
  ExerciseOption(name: 'Elliptical', key: 'elliptical', category: 'cardio'),
  ExerciseOption(
      name: 'Stair Climbing', key: 'stair_climbing', category: 'cardio'),
  ExerciseOption(name: 'Tennis', key: 'tennis', category: 'sports'),
  ExerciseOption(name: 'Basketball', key: 'basketball', category: 'sports'),
  ExerciseOption(name: 'Volleyball', key: 'volleyball', category: 'sports'),
  ExerciseOption(name: 'Skipping', key: 'skipping', category: 'cardio'),
  ExerciseOption(name: 'Hiking', key: 'hiking', category: 'cardio'),
  ExerciseOption(
      name: 'Surya Namaskar', key: 'surya_namaskar', category: 'flexibility'),
];
