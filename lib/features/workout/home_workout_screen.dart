import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/data/workout_library.dart';
import 'package:nutri_tracker/features/workout/workout_plan_detail_screen.dart';
import 'package:nutri_tracker/models/workout_plan.dart';

class HomeWorkoutScreen extends StatefulWidget {
  const HomeWorkoutScreen({super.key});

  @override
  State<HomeWorkoutScreen> createState() => _HomeWorkoutScreenState();
}

class _HomeWorkoutScreenState extends State<HomeWorkoutScreen> {
  String _selectedCategory = 'All';

  static const _categories = [
    'All',
    'strength',
    'hiit',
    'yoga',
    'cardio',
    'stretching',
  ];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please sign in.')));
    }

    final plans = _selectedCategory == 'All'
        ? kWorkoutLibrary
        : kWorkoutLibrary
            .where((plan) => plan.category == _selectedCategory)
            .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Home Workouts')),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                return FilterChip(
                  selected: _selectedCategory == category,
                  showCheckmark: false,
                  label: Text(_titleCase(category)),
                  onSelected: (_) {
                    setState(() => _selectedCategory = category);
                  },
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: plans.length,
              itemBuilder: (context, index) => _WorkoutPlanCard(
                plan: plans[index],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _WorkoutPlanCard extends StatelessWidget {
  const _WorkoutPlanCard({required this.plan});

  final WorkoutPlan plan;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(plan.emoji, style: const TextStyle(fontSize: 22)),
        ),
        title: Text(plan.name),
        subtitle: Text(
          '${plan.durationMinutes} min  \u{2022}  ${plan.estimatedCalories} kcal  \u{2022}  ${plan.difficulty}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkoutPlanDetailScreen(plan: plan),
          ),
        ),
      ),
    );
  }
}
