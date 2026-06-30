import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_tracker/models/workout_entry.dart';
import 'package:nutri_tracker/models/workout_plan.dart';
import 'package:nutri_tracker/routes/app_routes.dart';
import 'package:nutri_tracker/services/workout_service.dart';

class WorkoutSessionScreen extends StatefulWidget {
  const WorkoutSessionScreen({super.key, required this.plan});

  final WorkoutPlan plan;

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  int _exerciseIndex = 0;
  int _setIndex = 0;
  bool _resting = false;
  int _remainingSeconds = 0;
  int _totalCalories = 0;
  Timer? _timer;
  bool _done = false;
  final WorkoutService _workoutService = WorkoutService();

  WorkoutExercise get _current => widget.plan.exercises[_exerciseIndex];

  @override
  void initState() {
    super.initState();
    _prepareCurrentExercise();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please sign in.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plan.name),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_exerciseIndex + 1) / widget.plan.exercises.length,
          ),
        ),
      ),
      body: _done
          ? _DoneView(plan: widget.plan, totalCalories: _totalCalories)
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Exercise ${_exerciseIndex + 1} of ${widget.plan.exercises.length}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Text(_current.emoji, style: const TextStyle(fontSize: 80)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _resting ? 'Rest' : _current.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                _SessionTarget(
                  exercise: _current,
                  setIndex: _setIndex,
                  resting: _resting,
                  remainingSeconds: _remainingSeconds,
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        _current.instructions,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: _ActionButton(
                      exercise: _current,
                      resting: _resting,
                      timer: _timer,
                      onSkipRest: _skipRest,
                      onStartTimer: () => _startTimer(),
                      onNextStep: _nextStep,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _prepareCurrentExercise() {
    _remainingSeconds =
        _current.durationSeconds > 0 ? _current.durationSeconds : 0;
  }

  void _startTimer([int? secondsOverride]) {
    _timer?.cancel();
    final seconds = secondsOverride ??
        (_resting ? _remainingSeconds : _current.durationSeconds);
    if (seconds <= 0) {
      _nextStep();
      return;
    }
    _remainingSeconds = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        _timer = null;
        return;
      }
      if (_remainingSeconds <= 1) {
        timer.cancel();
        _timer = null;
        _nextStep();
        return;
      }
      setState(() => _remainingSeconds--);
    });
    if (mounted) setState(() {});
  }

  void _skipRest() {
    _timer?.cancel();
    _timer = null;
    if (!mounted) return;
    setState(() {
      _resting = false;
      _prepareCurrentExercise();
    });
  }

  void _nextStep() {
    _timer?.cancel();
    _timer = null;

    if (_resting) {
      if (!mounted) return;
      setState(() {
        _resting = false;
        _prepareCurrentExercise();
      });
      return;
    }

    final perExerciseCal =
        widget.plan.estimatedCalories / widget.plan.exercises.length;
    final nextCalories =
        _totalCalories + (perExerciseCal / _current.sets).round();
    _totalCalories = nextCalories > widget.plan.estimatedCalories
        ? widget.plan.estimatedCalories
        : nextCalories;

    if (_setIndex + 1 < _current.sets) {
      final restSeconds = _current.restSeconds;
      if (!mounted) return;
      setState(() {
        _setIndex++;
        _resting = true;
        _remainingSeconds = restSeconds;
      });
      if (restSeconds > 0) _startTimer(restSeconds);
    } else if (_exerciseIndex + 1 < widget.plan.exercises.length) {
      final restSeconds = _current.restSeconds;
      if (!mounted) return;
      setState(() {
        _exerciseIndex++;
        _setIndex = 0;
        _resting = true;
        _remainingSeconds = restSeconds;
      });
      if (restSeconds > 0) _startTimer(restSeconds);
    } else {
      _finishWorkout();
    }
  }

  Future<void> _finishWorkout() async {
    if (mounted) setState(() => _done = true);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final entry = ExerciseEntry(
      id: '',
      name: widget.plan.name,
      category: widget.plan.category,
      durationMinutes: widget.plan.durationMinutes,
      caloriesBurned: _totalCalories,
      timestamp: DateTime.now(),
      notes: 'Guided workout: ${widget.plan.name}',
    );
    await _workoutService.logWorkout(uid, entry);
  }
}

class _SessionTarget extends StatelessWidget {
  const _SessionTarget({
    required this.exercise,
    required this.setIndex,
    required this.resting,
    required this.remainingSeconds,
  });

  final WorkoutExercise exercise;
  final int setIndex;
  final bool resting;
  final int remainingSeconds;

  @override
  Widget build(BuildContext context) {
    if (resting) {
      return Column(
        children: [
          Text('Next: ${exercise.name}',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            '$remainingSeconds s',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 64,
                  color: remainingSeconds <= 3 ? Colors.red : null,
                ),
          ),
        ],
      );
    }
    if (exercise.durationSeconds > 0) {
      final progress = exercise.durationSeconds == 0
          ? 0.0
          : remainingSeconds / exercise.durationSeconds;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            Text(
              '$remainingSeconds s remaining',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress.clamp(0.0, 1.0)),
          ],
        ),
      );
    }
    return Column(
      children: [
        Text(
          'Set ${setIndex + 1} of ${exercise.sets}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          '${exercise.reps} reps',
          style: Theme.of(context).textTheme.displaySmall,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.exercise,
    required this.resting,
    required this.timer,
    required this.onSkipRest,
    required this.onStartTimer,
    required this.onNextStep,
  });

  final WorkoutExercise exercise;
  final bool resting;
  final Timer? timer;
  final VoidCallback onSkipRest;
  final VoidCallback onStartTimer;
  final VoidCallback onNextStep;

  @override
  Widget build(BuildContext context) {
    if (resting) {
      return FilledButton.icon(
        icon: const Icon(Icons.skip_next),
        label: const Text('Skip Rest'),
        onPressed: onSkipRest,
      );
    }
    if (exercise.durationSeconds > 0 && timer == null) {
      return FilledButton.icon(
        icon: const Icon(Icons.play_arrow),
        label: const Text('Start'),
        onPressed: onStartTimer,
      );
    }
    if (exercise.durationSeconds > 0) {
      return FilledButton.icon(
        icon: const Icon(Icons.check),
        label: const Text('Done Early'),
        onPressed: onNextStep,
      );
    }
    return FilledButton.icon(
      icon: const Icon(Icons.check),
      label: const Text('Set Done'),
      onPressed: onNextStep,
    );
  }
}

class _DoneView extends StatelessWidget {
  const _DoneView({required this.plan, required this.totalCalories});

  final WorkoutPlan plan;
  final int totalCalories;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('\u{1F389}', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'Workout Complete!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${plan.durationMinutes} min  \u{2022}  ~$totalCalories kcal burned',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Back to Home'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('Do it again'),
            ),
          ],
        ),
      ),
    );
  }
}
