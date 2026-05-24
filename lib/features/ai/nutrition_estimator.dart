import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/models/meal_entry.dart';
import 'package:nutri_tracker/services/ai_service.dart';
import 'package:nutri_tracker/services/calorie_service.dart';

class NutritionEstimatorScreen extends StatefulWidget {
  const NutritionEstimatorScreen({super.key});

  @override
  State<NutritionEstimatorScreen> createState() =>
      _NutritionEstimatorScreenState();
}

class _NutritionEstimatorScreenState extends State<NutritionEstimatorScreen> {
  final _controller = TextEditingController();
  final _ai = AIService();
  Map<String, dynamic>? _result;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition Estimator')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _controller,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Describe your meal',
              hintText: '2 rotis with dal and a glass of lassi',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _loading ? null : _estimate,
            icon: const Icon(Icons.auto_awesome),
            label: Text(_loading ? 'Estimating...' : 'Estimate Nutrition'),
          ),
          if (_result != null) _NutritionCard(result: _result!),
        ],
      ),
    );
  }

  Future<void> _estimate() async {
    setState(() => _loading = true);
    try {
      final result = await _ai.estimateNutrition(_controller.text.trim());
      if (mounted) setState(() => _result = result);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to estimate nutrition: $error')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _NutritionCard extends StatelessWidget {
  const _NutritionCard({required this.result});

  final Map<String, dynamic> result;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result['mealName'] ?? 'Meal',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Calories: ~${result['calories']} kcal'),
            Text('Protein: ${result['protein']}g'),
            Text('Carbs: ${result['carbs']}g'),
            Text('Fat: ${result['fat']}g'),
            Text('Fiber: ${result['fiber']}g'),
            Text('Confidence: ${result['confidence']}'),
            const SizedBox(height: 8),
            Text(result['notes'] ?? ''),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid == null) return;
                await CalorieService().addMealEntry(
                  uid,
                  DateTime.now(),
                  MealEntry(
                    mealType: 'snack',
                    foodName: result['mealName'] ?? 'Estimated meal',
                    calories: (result['calories'] as num?)?.toInt() ?? 0,
                    protein: (result['protein'] as num?)?.toDouble() ?? 0,
                    carbs: (result['carbs'] as num?)?.toDouble() ?? 0,
                    fat: (result['fat'] as num?)?.toDouble() ?? 0,
                    quantity: 1,
                    unit: 'serving',
                  ),
                );
              },
              child: const Text('Log this meal'),
            ),
          ],
        ),
      ),
    );
  }
}
