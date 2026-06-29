import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nutri_tracker/database/user_model.dart';
import 'package:nutri_tracker/models/meal_entry.dart';
import 'package:nutri_tracker/routes/app_routes.dart';
import 'package:nutri_tracker/services/calorie_service.dart';
import 'package:nutri_tracker/services/firestore_service.dart';
import 'package:nutri_tracker/widgets/water_tracker_widget.dart';

class NutritionHomeScreen extends StatefulWidget {
  const NutritionHomeScreen({super.key});

  @override
  State<NutritionHomeScreen> createState() => _NutritionHomeScreenState();
}

class _NutritionHomeScreenState extends State<NutritionHomeScreen> {
  final _calorieService = CalorieService();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please sign in.')));
    }
    return StreamBuilder<UserModel>(
      stream: FirestoreService().watchUser(uid),
      builder: (context, userSnapshot) {
        final goal = userSnapshot.data?.dailyCalorieGoal ?? 2000;
        return StreamBuilder<DailyCalorieLog>(
          stream: _calorieService.watchDailyLog(uid, _selectedDate),
          builder: (context, snapshot) {
            final log = snapshot.data ??
                DailyCalorieLog.empty(_calorieService.dateKey(_selectedDate));
            return Scaffold(
              appBar: AppBar(
                title: const Text('Nutrition'),
                actions: [
                  IconButton(
                    tooltip: 'Meal plan',
                    onPressed: () => context.push(AppRoutes.mealPlan),
                    icon: const Icon(Icons.calendar_month_outlined),
                  ),
                  IconButton(
                    tooltip: 'AI estimator',
                    onPressed: () => context.push(AppRoutes.nutritionEstimator),
                    icon: const Icon(Icons.auto_awesome_outlined),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () => context.push(
                  AppRoutes.nutritionAdd,
                  extra: {'date': _selectedDate, 'mealType': 'snack'},
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add meal'),
              ),
              body: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                children: [
                  _DateSelector(
                    selectedDate: _selectedDate,
                    onChanged: (date) => setState(() => _selectedDate = date),
                  ),
                  const SizedBox(height: 12),
                  _DailyRing(log: log, goal: goal),
                  const SizedBox(height: 12),
                  _MacroProgress(log: log),
                  const SizedBox(height: 12),
                  for (final mealType in const [
                    'breakfast',
                    'lunch',
                    'dinner',
                    'snack',
                  ])
                    _MealSection(
                      date: _selectedDate,
                      mealType: mealType,
                      meals: log.meals
                          .where((meal) => meal.mealType == mealType)
                          .toList(),
                    ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: WaterTrackerWidget(
                        uid: uid,
                        date: _selectedDate,
                        waterIntakeMl: log.waterIntakeMl,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({
    required this.selectedDate,
    required this.onChanged,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Previous day',
          onPressed: () =>
              onChanged(selectedDate.subtract(const Duration(days: 1))),
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Center(
            child: Text(
              DateFormat('EEE, d MMM').format(selectedDate),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Next day',
          onPressed: () => onChanged(selectedDate.add(const Duration(days: 1))),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _DailyRing extends StatelessWidget {
  const _DailyRing({required this.log, required this.goal});

  final DailyCalorieLog log;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final consumed = log.totalCalories;
    final burned = log.caloriesBurned;
    final net = consumed - burned;
    final remaining = goal - net;
    final percent = (consumed / goal).clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            SizedBox(
              height: 112,
              width: 112,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(strokeWidth: 12, value: percent),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$consumed',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const Text('kcal'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _MiniMetric(label: 'Goal', value: '$goal'),
                  _MiniMetric(label: 'Burned', value: '$burned'),
                  _MiniMetric(label: 'Net', value: '$net'),
                  _MiniMetric(label: 'Remaining', value: '$remaining'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroProgress extends StatelessWidget {
  const _MacroProgress({required this.log});

  final DailyCalorieLog log;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Macros', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _MacroRow(label: 'Protein', value: log.totalProtein, target: 100),
            _MacroRow(label: 'Carbs', value: log.totalCarbs, target: 250),
            _MacroRow(label: 'Fat', value: log.totalFat, target: 65),
            _MacroRow(label: 'Fiber', value: log.totalFiber, target: 30),
          ],
        ),
      ),
    );
  }
}

class _MealSection extends StatelessWidget {
  const _MealSection({
    required this.date,
    required this.mealType,
    required this.meals,
  });

  final DateTime date;
  final String mealType;
  final List<MealEntry> meals;

  @override
  Widget build(BuildContext context) {
    final total = meals.fold<int>(0, (sum, meal) => sum + meal.calories);
    return Card(
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(toBeginningOfSentenceCase(mealType) ?? mealType),
        subtitle: Text('$total kcal'),
        trailing: IconButton(
          tooltip: 'Add ${mealType == 'snack' ? 'snack' : mealType}',
          onPressed: () => context.push(
            AppRoutes.nutritionAdd,
            extra: {'date': date, 'mealType': mealType},
          ),
          icon: const Icon(Icons.add_circle_outline),
        ),
        children: [
          if (meals.isEmpty)
            const ListTile(title: Text('No foods logged yet.')),
          for (final meal in meals)
            ListTile(
              title: Text(meal.foodName),
              subtitle: Text(meal.servingDescription ??
                  '${meal.quantity.toStringAsFixed(0)} ${meal.unit}'),
              trailing: Text('${meal.calories} kcal'),
              onTap: () => context.push(
                AppRoutes.nutritionMealDetail,
                extra: {'date': date, 'meal': meal},
              ),
            ),
        ],
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({
    required this.label,
    required this.value,
    required this.target,
  });

  final String label;
  final double value;
  final double target;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(width: 72, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(
              value: (value / max(target, 1)).clamp(0.0, 1.0),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 78,
            child: Text('${value.toStringAsFixed(0)} / ${target.round()}g'),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
