import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/models/meal_plan.dart';
import 'package:nutri_tracker/services/ai_service.dart';
import 'package:nutri_tracker/services/firestore_service.dart';
import 'package:nutri_tracker/utils/health_utils.dart';
import 'package:share_plus/share_plus.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  final _ai = AIService();
  int _days = 1;
  int _calories = 1800;
  String _diet = 'vegetarian';
  String _goal = 'maintain';
  String _cuisine = 'Mixed';
  MealPlan? _plan;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Meal Plan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<int>(
            value: _days,
            decoration: const InputDecoration(labelText: 'Duration'),
            items: const [
              DropdownMenuItem(value: 1, child: Text('1 day')),
              DropdownMenuItem(value: 3, child: Text('3 days')),
              DropdownMenuItem(value: 7, child: Text('7 days')),
            ],
            onChanged: (value) => setState(() => _days = value ?? 1),
          ),
          TextFormField(
            initialValue: '$_calories',
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Calorie target'),
            onChanged: (value) => _calories = int.tryParse(value) ?? _calories,
          ),
          DropdownButtonFormField<String>(
            value: _diet,
            decoration: const InputDecoration(labelText: 'Diet'),
            items: const [
              DropdownMenuItem(value: 'vegetarian', child: Text('Vegetarian')),
              DropdownMenuItem(value: 'non_vegetarian', child: Text('Non-veg')),
              DropdownMenuItem(value: 'vegan', child: Text('Vegan')),
              DropdownMenuItem(value: 'eggetarian', child: Text('Eggetarian')),
            ],
            onChanged: (value) => setState(() => _diet = value ?? _diet),
          ),
          DropdownButtonFormField<String>(
            value: _goal,
            decoration: const InputDecoration(labelText: 'Goal'),
            items: const [
              DropdownMenuItem(value: 'lose', child: Text('Lose weight')),
              DropdownMenuItem(value: 'maintain', child: Text('Maintain')),
              DropdownMenuItem(value: 'gain', child: Text('Gain weight')),
            ],
            onChanged: (value) => setState(() => _goal = value ?? _goal),
          ),
          DropdownButtonFormField<String>(
            value: _cuisine,
            decoration: const InputDecoration(labelText: 'Cuisine'),
            items: const [
              DropdownMenuItem(
                  value: 'North Indian', child: Text('North Indian')),
              DropdownMenuItem(
                  value: 'South Indian', child: Text('South Indian')),
              DropdownMenuItem(value: 'Mixed', child: Text('Mixed')),
            ],
            onChanged: (value) => setState(() => _cuisine = value ?? _cuisine),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loading ? null : _generate,
            icon: const Icon(Icons.auto_awesome),
            label: Text(_loading ? 'Generating...' : 'Generate'),
          ),
          if (_plan != null) _MealPlanView(plan: _plan!),
        ],
      ),
    );
  }

  Future<void> _generate() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _loading = true);
    try {
      final user = await FirestoreService().getUser(uid);
      final response = await _ai.sendMessage(
        userMessage: buildMealPlanPrompt(
          days: _days,
          calorieTarget: _calories,
          dietaryPreference: _diet,
          goal: _goal,
          cuisinePreference: _cuisine,
          userBmi: user.bmi,
        ),
        conversationHistory: const [],
      );
      final jsonText = _extractJsonObject(response);
      if (jsonText == null) {
        throw const FormatException(
            'The AI response did not contain a JSON meal plan.');
      }
      setState(() => _plan = MealPlan.fromJson(jsonDecode(jsonText)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to generate meal plan: $error')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

String? _extractJsonObject(String value) {
  final start = value.indexOf('{');
  final end = value.lastIndexOf('}');
  if (start == -1 || end == -1 || end <= start) return null;
  return value.substring(start, end + 1);
}

class _MealPlanView extends StatelessWidget {
  const _MealPlanView({required this.plan});

  final MealPlan plan;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: plan.days.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: plan.days.map((day) => Tab(text: 'Day ${day.day}')).toList(),
          ),
          SizedBox(
            height: 420,
            child: TabBarView(
              children: plan.days.map((day) {
                return ListView(
                  children: [
                    ListTile(
                      title: Text('${day.totalCalories} kcal'),
                      trailing: IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () => Share.share(
                          day.meals.values
                              .map(
                                  (meal) => '${meal.name}: ${meal.description}')
                              .join('\n'),
                        ),
                      ),
                    ),
                    for (final entry in day.meals.entries)
                      ListTile(
                        title: Text(entry.value.name),
                        subtitle: Text(entry.value.description),
                        trailing: Text('${entry.value.calories} kcal'),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

String buildMealPlanPrompt({
  required int days,
  required int calorieTarget,
  required String dietaryPreference,
  required String goal,
  required String cuisinePreference,
  required String? userBmi,
}) {
  final bmi = double.tryParse(userBmi ?? '0') ?? 0;
  return '''
Create a $days-day Indian meal plan with these requirements:
- Daily calorie target: $calorieTarget calories
- Dietary preference: $dietaryPreference
- Goal: $goal
- Cuisine: $cuisinePreference
- BMI: ${userBmi ?? 'not set'} (${getBmiCategory(bmi)})

For each day provide breakfast, lunch, dinner, and 2 snacks.
Use common Indian foods. Include portion sizes.

Respond ONLY with JSON in this format:
{"days":[{"day":1,"totalCalories":1800,"meals":{"breakfast":{"name":"Oats Upma","calories":280,"description":"1 cup oats upma with vegetables"},"morningSnack":{"name":"Buttermilk","calories":60,"description":"1 glass low-fat buttermilk"},"lunch":{"name":"Dal Rice + Sabzi","calories":550,"description":"1 cup dal, 1 cup rice, 1 cup mixed sabzi"},"eveningSnack":{"name":"Sprouts chaat","calories":120,"description":"1 cup moong sprouts with lemon"},"dinner":{"name":"2 Rotis + Paneer Bhurji","calories":400,"description":"2 whole wheat rotis + 100g paneer bhurji"}}}]}
''';
}
