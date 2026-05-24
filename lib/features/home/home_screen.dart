import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide NavigationDrawer;
import 'package:intl/intl.dart';
import 'package:nutri_tracker/bmi/screens/calculator_screen.dart';
import 'package:nutri_tracker/database/user_model.dart';
import 'package:nutri_tracker/drawer/drawermenu.dart';
import 'package:nutri_tracker/features/ai/ai_assistant_screen.dart';
import 'package:nutri_tracker/features/calories/calorie_log_screen.dart';
import 'package:nutri_tracker/homepage/home/quotes.dart';
import 'package:nutri_tracker/models/indian_recipe.dart';
import 'package:nutri_tracker/models/meal_entry.dart';
import 'package:nutri_tracker/services/calorie_service.dart';
import 'package:nutri_tracker/services/firestore_service.dart';
import 'package:nutri_tracker/services/recipe_api_service.dart';
import 'package:nutri_tracker/utils/health_utils.dart';
import 'package:nutri_tracker/widgets/bmi_gauge_widget.dart';
import 'package:nutri_tracker/widgets/macro_chart_widget.dart';
import 'package:nutri_tracker/widgets/water_tracker_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firestoreService = FirestoreService();
  final _calorieService = CalorieService();
  final _recipeApi = RecipeApiService();
  final quote = mylist[Random().nextInt(mylist.length)];
  late final Future<IndianRecipe?> _featuredRecipeFuture;

  @override
  void initState() {
    super.initState();
    _featuredRecipeFuture = _recipeApi.randomIndianRecipe();
  }

  String greetings() {
    final hour = DateTime.now().hour;
    if (hour <= 12) return 'Morning';
    if (hour <= 16) return 'Afternoon';
    return 'Evening';
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null)
      return const Scaffold(body: Center(child: Text('Please sign in.')));
    return StreamBuilder<UserModel>(
      stream: _firestoreService.watchUser(uid),
      builder: (context, userSnapshot) {
        final user = userSnapshot.data ?? UserModel();
        final bmi = double.tryParse(user.bmi ?? '0') ?? 0;
        final goal = user.dailyCalorieGoal ?? 2000;
        return Scaffold(
          appBar: AppBar(title: const Text('NutriTrack India')),
          drawer: NavigationDrawer(),
          body: StreamBuilder(
            stream: _calorieService.watchDailyLog(uid, DateTime.now()),
            builder: (context, logSnapshot) {
              final log = logSnapshot.data ??
                  DailyCalorieLog.empty(
                      _calorieService.dateKey(DateTime.now()));
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Good ${greetings()}, ${user.name ?? 'there'}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(DateFormat('EEEE, d MMMM').format(DateTime.now())),
                  const SizedBox(height: 12),
                  Card(
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CalorieLogScreen()),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Today's Summary",
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: (log.totalCalories / goal).clamp(0.0, 1.0),
                            ),
                            const SizedBox(height: 8),
                            Text('${log.totalCalories} / $goal kcal'),
                            Row(
                              children: [
                                MacroChartWidget(
                                  protein: log.totalProtein,
                                  carbs: log.totalCarbs,
                                  fat: log.totalFat,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: WaterTrackerWidget(
                                    uid: uid,
                                    date: DateTime.now(),
                                    waterIntakeMl: log.waterIntakeMl,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('BMI Status',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          if (bmi <= 0)
                            FilledButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => CalculatorScreen()),
                              ),
                              child: const Text('Calculate your BMI'),
                            )
                          else
                            BmiGaugeWidget(bmi: bmi),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _QuickAction(
                        icon: Icons.restaurant_menu,
                        label: 'Log Meal',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CalorieLogScreen()),
                        ),
                      ),
                      _QuickAction(
                        icon: Icons.water_drop,
                        label: 'Log Water',
                        onTap: () => showModalBottomSheet<void>(
                          context: context,
                          builder: (_) => Padding(
                            padding: const EdgeInsets.all(24),
                            child: WaterTrackerWidget(
                              uid: uid,
                              date: DateTime.now(),
                              waterIntakeMl: log.waterIntakeMl,
                            ),
                          ),
                        ),
                      ),
                      _QuickAction(
                        icon: Icons.monitor_weight,
                        label: 'Weigh In',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => CalculatorScreen()),
                        ),
                      ),
                      _QuickAction(
                        icon: Icons.auto_awesome,
                        label: 'NutriBot',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AIAssistantScreen()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text("Today's Recommended Meals",
                      style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(
                    height: 180,
                    child: _RecommendedFoods(
                      bmiCategory: getBmiCategory(bmi),
                      dietaryPreference: user.dietaryPreference,
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(quote.quote ?? ''),
                          const SizedBox(height: 8),
                          Text('- ${quote.auther ?? 'NutriTrack India'}'),
                        ],
                      ),
                    ),
                  ),
                  FutureBuilder(
                    future: _featuredRecipeFuture,
                    builder: (context, snapshot) {
                      final recipe = snapshot.data;
                      if (recipe == null) return const SizedBox.shrink();
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              recipe.thumbnailUrl,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text('Featured: ${recipe.name}',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _RecommendedFoods extends StatelessWidget {
  const _RecommendedFoods({required this.bmiCategory, this.dietaryPreference});

  final String bmiCategory;
  final String? dietaryPreference;

  @override
  Widget build(BuildContext context) {
    var query = FirebaseFirestore.instance.collection('indian_foods').limit(3);
    if (dietaryPreference != null && dietaryPreference!.isNotEmpty) {
      query = query.where('dietType', isEqualTo: dietaryPreference);
    }
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
              child: Text('Seed Indian foods to see suggestions.'));
        }
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final food = docs[index].data();
            return SizedBox(
              width: 210,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(food['name'] ?? 'Food',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('${food['caloriesPer100g'] ?? 0} kcal / 100g'),
                      Text(food['cuisine'] ?? ''),
                      const Spacer(),
                      Chip(label: Text(bmiCategory)),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(child: Icon(icon)),
          const SizedBox(height: 6),
          Text(label),
        ],
      ),
    );
  }
}
