import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_tracker/routes/app_routes.dart';
import 'package:nutri_tracker/utils/health_utils.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _page = PageController();
  int _index = 0;
  int _age = 25;
  double _height = 165;
  double _weight = 65;
  double _targetWeight = 65;
  String _gender = 'Female';
  String _goal = 'maintain';
  String _diet = 'vegetarian';
  String _activity = 'sedentary';
  String _fitnessLevel = 'beginner';
  String _equipment = 'none';
  int _workoutDuration = 30;
  final Set<String> _workoutDays = {'Mon', 'Wed', 'Fri'};
  final _injuriesController = TextEditingController();
  final _allergiesController = TextEditingController();

  int get _calorieGoal {
    final bmr = calculateBmr(
      gender: _gender,
      weightKg: _weight,
      heightCm: _height,
      age: _age,
    );
    final adjustment = _goal == 'lose'
        ? -300
        : _goal == 'gain'
            ? 300
            : 0;
    return (bmr * activityMultiplier(_activity) + adjustment).round();
  }

  @override
  void dispose() {
    _page.dispose();
    _injuriesController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _page,
                onPageChanged: (value) => setState(() => _index = value),
                children: [
                  _Step(
                    title: 'Welcome to NutriTrack India',
                    child: Icon(Icons.local_dining,
                        size: 120,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  _Step(
                    title: 'Tell us about yourself',
                    child: Column(
                      children: [
                        _SliderRow(
                            label: 'Age',
                            value: _age.toDouble(),
                            min: 10,
                            max: 90,
                            onChanged: (v) => setState(() => _age = v.round())),
                        _SliderRow(
                            label: 'Height cm',
                            value: _height,
                            min: 120,
                            max: 220,
                            onChanged: (v) => setState(() => _height = v)),
                        _SliderRow(
                            label: 'Weight kg',
                            value: _weight,
                            min: 30,
                            max: 180,
                            onChanged: (v) => setState(() => _weight = v)),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'Male', label: Text('Male')),
                            ButtonSegment(
                                value: 'Female', label: Text('Female')),
                          ],
                          selected: {_gender},
                          onSelectionChanged: (v) =>
                              setState(() => _gender = v.first),
                        ),
                      ],
                    ),
                  ),
                  _Step(
                    title: "What's your goal?",
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _goal,
                          items: const [
                            DropdownMenuItem(
                                value: 'lose', child: Text('Lose weight')),
                            DropdownMenuItem(
                                value: 'maintain', child: Text('Maintain')),
                            DropdownMenuItem(
                                value: 'gain', child: Text('Gain weight')),
                          ],
                          onChanged: (v) => setState(() => _goal = v ?? _goal),
                        ),
                        DropdownButtonFormField<String>(
                          value: _diet,
                          items: const [
                            DropdownMenuItem(
                                value: 'vegetarian', child: Text('Vegetarian')),
                            DropdownMenuItem(
                                value: 'non_vegetarian',
                                child: Text('Non-vegetarian')),
                            DropdownMenuItem(
                                value: 'vegan', child: Text('Vegan')),
                            DropdownMenuItem(
                                value: 'eggetarian', child: Text('Eggetarian')),
                          ],
                          onChanged: (v) => setState(() => _diet = v ?? _diet),
                        ),
                      ],
                    ),
                  ),
                  _Step(
                    title: 'Set your activity level',
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _activity,
                          items: const [
                            DropdownMenuItem(
                                value: 'sedentary', child: Text('Sedentary')),
                            DropdownMenuItem(
                                value: 'lightly_active',
                                child: Text('Lightly active')),
                            DropdownMenuItem(
                                value: 'moderately_active',
                                child: Text('Moderately active')),
                            DropdownMenuItem(
                                value: 'very_active',
                                child: Text('Very active')),
                          ],
                          onChanged: (v) =>
                              setState(() => _activity = v ?? _activity),
                        ),
                        const SizedBox(height: 24),
                        Text('Your daily calorie goal: $_calorieGoal kcal',
                            style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                  ),
                  _Step(
                    title: 'Plan your home workouts',
                    child: Column(
                      children: [
                        _SliderRow(
                          label: 'Target weight kg',
                          value: _targetWeight,
                          min: 30,
                          max: 180,
                          onChanged: (v) => setState(() => _targetWeight = v),
                        ),
                        DropdownButtonFormField<String>(
                          value: _fitnessLevel,
                          items: const [
                            DropdownMenuItem(
                                value: 'beginner', child: Text('Beginner')),
                            DropdownMenuItem(
                                value: 'intermediate',
                                child: Text('Intermediate')),
                            DropdownMenuItem(
                                value: 'advanced', child: Text('Advanced')),
                          ],
                          onChanged: (v) => setState(
                              () => _fitnessLevel = v ?? _fitnessLevel),
                        ),
                        DropdownButtonFormField<String>(
                          value: _equipment,
                          items: const [
                            DropdownMenuItem(
                                value: 'none', child: Text('No equipment')),
                            DropdownMenuItem(
                                value: 'dumbbells', child: Text('Dumbbells')),
                            DropdownMenuItem(
                                value: 'resistance_band',
                                child: Text('Resistance band')),
                            DropdownMenuItem(
                                value: 'full_gym', child: Text('Full gym')),
                          ],
                          onChanged: (v) =>
                              setState(() => _equipment = v ?? _equipment),
                        ),
                        _SliderRow(
                          label: 'Workout minutes',
                          value: _workoutDuration.toDouble(),
                          min: 10,
                          max: 90,
                          onChanged: (v) =>
                              setState(() => _workoutDuration = v.round()),
                        ),
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
                                selected: _workoutDays.contains(day),
                                label: Text(day),
                                onSelected: (selected) {
                                  setState(() {
                                    selected
                                        ? _workoutDays.add(day)
                                        : _workoutDays.remove(day);
                                  });
                                },
                              ),
                          ],
                        ),
                        TextField(
                          controller: _injuriesController,
                          decoration: const InputDecoration(
                            labelText: 'Injuries or limitations',
                          ),
                        ),
                        TextField(
                          controller: _allergiesController,
                          decoration: const InputDecoration(
                            labelText: 'Allergies',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text('${_index + 1}/5'),
                  const Spacer(),
                  FilledButton(
                    onPressed: _index == 4 ? _finish : _next,
                    child: Text(_index == 4 ? 'Finish' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _next() {
    _page.nextPage(
        duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  Future<void> _finish() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final bmi = calculateBmi(_weight, _height);
    await FirebaseFirestore.instance.collection('user_details').doc(uid).set({
      'uid': uid,
      'height': _height.toStringAsFixed(0),
      'weight': _weight.toStringAsFixed(1),
      'targetWeight': _targetWeight,
      'gender': _gender,
      'bmi': bmi.toStringAsFixed(1),
      'bmr': calculateBmr(
              gender: _gender, weightKg: _weight, heightCm: _height, age: _age)
          .toStringAsFixed(0),
      'weightGoal': _goal,
      'dietaryPreference': _diet,
      'activityLevel': _activity,
      'dailyCalorieGoal': _calorieGoal,
      'fitnessLevel': _fitnessLevel,
      'equipment': _equipment,
      'preferredWorkoutDays': _workoutDays.toList(),
      'workoutDurationMinutes': _workoutDuration,
      'injuriesOrLimitations': _injuriesController.text.trim(),
      'allergies': _allergiesController.text
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(),
      'isOnboardingDone': true,
      'lastBmiDate': Timestamp.now(),
    }, SetOptions(merge: true));
    if (!mounted) return;
    context.go(AppRoutes.dashboard);
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 28),
          child,
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.round()}'),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}
