import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/models/user_goal.dart';
import 'package:nutri_tracker/repositories/goal_repository.dart';
import 'package:nutri_tracker/utils/health_utils.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _repository = GoalRepository();
  final _targetWeight = TextEditingController();
  final _injuries = TextEditingController();
  final _allergies = TextEditingController();
  String _goalType = 'maintain';
  String _fitnessLevel = 'beginner';
  String _equipment = 'none';
  String _diet = 'vegetarian';
  int _calorieGoal = 2000;
  int _proteinGoal = 100;
  int _waterGoal = 2500;
  int _stepGoal = 8000;
  int _workoutsPerWeek = 4;
  int _duration = 30;
  final Set<String> _days = {'Mon', 'Tue', 'Thu', 'Sat'};
  bool _saving = false;
  bool _hydrated = false;

  @override
  void dispose() {
    _targetWeight.dispose();
    _injuries.dispose();
    _allergies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please sign in.')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: StreamBuilder<UserGoal?>(
        stream: _repository.watchActiveGoal(uid),
        builder: (context, snapshot) {
          final active = snapshot.data;
          if (active != null && !_hydrated) {
            _hydrate(active);
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<String>(
                value: _goalType,
                decoration: const InputDecoration(labelText: 'Goal type'),
                items: const [
                  DropdownMenuItem(
                    value: 'lose_weight',
                    child: Text('Lose weight'),
                  ),
                  DropdownMenuItem(value: 'maintain', child: Text('Maintain')),
                  DropdownMenuItem(
                    value: 'gain_muscle',
                    child: Text('Gain muscle'),
                  ),
                  DropdownMenuItem(
                    value: 'improve_fitness',
                    child: Text('Improve fitness'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _goalType = value ?? _goalType),
              ),
              TextField(
                controller: _targetWeight,
                decoration:
                    const InputDecoration(labelText: 'Target weight kg'),
                keyboardType: TextInputType.number,
              ),
              _SliderField(
                label: 'Daily calories',
                value: _calorieGoal,
                min: 1200,
                max: 4000,
                step: 50,
                onChanged: (value) => setState(() {
                  _calorieGoal = value;
                  final macros = calculateMacroTargets(
                    calorieGoal: value,
                    goalType: _goalType,
                  );
                  _proteinGoal = macros.proteinGoalG;
                }),
              ),
              _SliderField(
                label: 'Protein goal g',
                value: _proteinGoal,
                min: 40,
                max: 240,
                step: 5,
                onChanged: (value) => setState(() => _proteinGoal = value),
              ),
              _SliderField(
                label: 'Water goal ml',
                value: _waterGoal,
                min: 1000,
                max: 5000,
                step: 250,
                onChanged: (value) => setState(() => _waterGoal = value),
              ),
              _SliderField(
                label: 'Step goal',
                value: _stepGoal,
                min: 3000,
                max: 20000,
                step: 500,
                onChanged: (value) => setState(() => _stepGoal = value),
              ),
              _SliderField(
                label: 'Workouts per week',
                value: _workoutsPerWeek,
                min: 1,
                max: 7,
                step: 1,
                onChanged: (value) => setState(() => _workoutsPerWeek = value),
              ),
              _SliderField(
                label: 'Workout duration minutes',
                value: _duration,
                min: 10,
                max: 90,
                step: 5,
                onChanged: (value) => setState(() => _duration = value),
              ),
              const SizedBox(height: 12),
              Text('Preferred workout days',
                  style: Theme.of(context).textTheme.titleMedium),
              Wrap(
                spacing: 8,
                children: [
                  for (final day in const [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun',
                  ])
                    FilterChip(
                      selected: _days.contains(day),
                      label: Text(day),
                      onSelected: (selected) {
                        setState(() {
                          selected ? _days.add(day) : _days.remove(day);
                        });
                      },
                    ),
                ],
              ),
              DropdownButtonFormField<String>(
                value: _fitnessLevel,
                decoration: const InputDecoration(labelText: 'Fitness level'),
                items: const [
                  DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                  DropdownMenuItem(
                    value: 'intermediate',
                    child: Text('Intermediate'),
                  ),
                  DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
                ],
                onChanged: (value) =>
                    setState(() => _fitnessLevel = value ?? _fitnessLevel),
              ),
              DropdownButtonFormField<String>(
                value: _equipment,
                decoration: const InputDecoration(labelText: 'Equipment'),
                items: const [
                  DropdownMenuItem(value: 'none', child: Text('None')),
                  DropdownMenuItem(
                      value: 'dumbbells', child: Text('Dumbbells')),
                  DropdownMenuItem(
                    value: 'resistance_band',
                    child: Text('Resistance band'),
                  ),
                  DropdownMenuItem(value: 'full_gym', child: Text('Full gym')),
                ],
                onChanged: (value) =>
                    setState(() => _equipment = value ?? _equipment),
              ),
              DropdownButtonFormField<String>(
                value: _diet,
                decoration: const InputDecoration(labelText: 'Diet preference'),
                items: const [
                  DropdownMenuItem(
                      value: 'vegetarian', child: Text('Vegetarian')),
                  DropdownMenuItem(value: 'vegan', child: Text('Vegan')),
                  DropdownMenuItem(
                    value: 'eggetarian',
                    child: Text('Eggetarian'),
                  ),
                  DropdownMenuItem(
                    value: 'non_vegetarian',
                    child: Text('Non-vegetarian'),
                  ),
                ],
                onChanged: (value) => setState(() => _diet = value ?? _diet),
              ),
              TextField(
                controller: _injuries,
                decoration: const InputDecoration(
                  labelText: 'Injuries or limitations',
                ),
                minLines: 1,
                maxLines: 3,
              ),
              TextField(
                controller: _allergies,
                decoration: const InputDecoration(
                  labelText: 'Allergies, comma separated',
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _saving ? null : () => _save(uid, active?.id ?? ''),
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: const Text('Save goals'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _hydrate(UserGoal goal) {
    _hydrated = true;
    if (_targetWeight.text.isEmpty && goal.targetWeightKg != null) {
      _targetWeight.text = goal.targetWeightKg!.toStringAsFixed(1);
    }
    _goalType = goal.goalType;
    _calorieGoal = goal.dailyCalorieGoal;
    _proteinGoal = goal.proteinGoalG;
    _waterGoal = goal.waterGoalMl;
    _stepGoal = goal.stepGoal;
    _workoutsPerWeek = goal.workoutsPerWeek;
    _duration = goal.workoutDurationMinutes;
    _fitnessLevel = goal.fitnessLevel;
    _equipment = goal.equipment;
    if (goal.dietPreference.isNotEmpty) _diet = goal.dietPreference;
    if (_injuries.text.isEmpty) _injuries.text = goal.injuriesOrLimitations;
    if (_allergies.text.isEmpty) _allergies.text = goal.allergies.join(', ');
    if (_days.isEmpty) _days.addAll(goal.preferredWorkoutDays);
  }

  Future<void> _save(String uid, String goalId) async {
    setState(() => _saving = true);
    try {
      final fatGoal = (_calorieGoal * 0.28 / 9).round();
      final carbsGoal =
          ((_calorieGoal - (_proteinGoal * 4) - (fatGoal * 9)) / 4).round();
      await _repository.saveGoal(
        UserGoal(
          id: goalId,
          uid: uid,
          goalType: _goalType,
          targetWeightKg: double.tryParse(_targetWeight.text.trim()),
          dailyCalorieGoal: _calorieGoal,
          proteinGoalG: _proteinGoal,
          carbsGoalG: carbsGoal,
          fatGoalG: fatGoal,
          waterGoalMl: _waterGoal,
          stepGoal: _stepGoal,
          workoutsPerWeek: _workoutsPerWeek,
          preferredWorkoutDays: _days.toList(),
          workoutDurationMinutes: _duration,
          fitnessLevel: _fitnessLevel,
          equipment: _equipment,
          injuriesOrLimitations: _injuries.text.trim(),
          dietPreference: _diet,
          allergies: _allergies.text
              .split(',')
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .toList(),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goals saved.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _SliderField extends StatelessWidget {
  const _SliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: $value'),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: ((max - min) / step).round(),
          label: '$value',
          onChanged: (next) => onChanged((next / step).round() * step),
        ),
      ],
    );
  }
}
