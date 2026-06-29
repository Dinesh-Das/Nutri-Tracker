import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nutri_tracker/features/calories/add_meal_bottom_sheet.dart';
import 'package:nutri_tracker/database/user_model.dart';
import 'package:nutri_tracker/models/meal_entry.dart';
import 'package:nutri_tracker/routes/app_routes.dart';
import 'package:nutri_tracker/services/calorie_service.dart';
import 'package:nutri_tracker/services/firestore_service.dart';
import 'package:nutri_tracker/widgets/water_tracker_widget.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CalorieLogScreen extends StatefulWidget {
  const CalorieLogScreen({super.key});

  @override
  State<CalorieLogScreen> createState() => _CalorieLogScreenState();
}

class _CalorieLogScreenState extends State<CalorieLogScreen> {
  final _service = CalorieService();
  final _firestoreService = FirestoreService();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Center(child: Text('Please sign in.'));

    return StreamBuilder<UserModel>(
      stream: _firestoreService.watchUser(uid),
      builder: (context, userSnapshot) {
        final goal = userSnapshot.data?.dailyCalorieGoal ?? 2000;
        return StreamBuilder<DailyCalorieLog>(
          stream: _service.watchDailyLog(uid, _selectedDate),
          builder: (context, snapshot) {
            final log = snapshot.data ??
                DailyCalorieLog.empty(_service.dateKey(_selectedDate));
            final percent = (log.totalCalories / goal).clamp(0.0, 1.0);
            return Scaffold(
              appBar: AppBar(title: const Text('Log')),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () => context.push(
                  AppRoutes.photoMeal,
                  extra: {
                    'date': _selectedDate,
                    'mealType': 'snack',
                  },
                ),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Photo'),
              ),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => setState(() {
                          _selectedDate =
                              _selectedDate.subtract(const Duration(days: 1));
                        }),
                      ),
                      Text(DateFormat('EEE, d MMM').format(_selectedDate),
                          style: Theme.of(context).textTheme.titleMedium),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => setState(() {
                          _selectedDate =
                              _selectedDate.add(const Duration(days: 1));
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: CircularPercentIndicator(
                      radius: 82,
                      lineWidth: 12,
                      percent: percent,
                      progressColor: Theme.of(context).colorScheme.primary,
                      center: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${log.totalCalories}',
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                          const Text('kcal'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('Protein ${log.totalProtein.toStringAsFixed(0)}g'),
                      Text('Carbs ${log.totalCarbs.toStringAsFixed(0)}g'),
                      Text('Fat ${log.totalFat.toStringAsFixed(0)}g'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  for (final mealType in const [
                    'breakfast',
                    'lunch',
                    'dinner',
                    'snack'
                  ])
                    _MealSection(
                      title: mealType,
                      meals: log.meals
                          .where((m) => m.mealType == mealType)
                          .toList(),
                      onAdd: () => showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => AddMealBottomSheet(
                          uid: uid,
                          date: _selectedDate,
                          mealType: mealType,
                        ),
                      ),
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
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => context.push(
                      AppRoutes.aiCoach,
                      extra:
                          "I've eaten ${log.totalCalories} calories today. Is that on track?",
                    ),
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Generate Meal Plan with AI'),
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

class _MealSection extends StatelessWidget {
  const _MealSection({
    required this.title,
    required this.meals,
    required this.onAdd,
  });

  final String title;
  final List<MealEntry> meals;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(toBeginningOfSentenceCase(title) ?? title),
        trailing: IconButton(
          tooltip: 'Add meal',
          icon: const Icon(Icons.add_circle_outline),
          onPressed: onAdd,
        ),
        children: [
          if (meals.isEmpty)
            const ListTile(title: Text('No foods logged yet.')),
          for (final meal in meals)
            ListTile(
              title: Text(meal.foodName),
              subtitle:
                  Text('${meal.quantity.toStringAsFixed(0)} ${meal.unit}'),
              trailing: Text('${meal.calories} kcal'),
            ),
        ],
      ),
    );
  }
}
