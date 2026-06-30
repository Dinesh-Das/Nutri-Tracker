import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_tracker/features/ai/ai_assistant_screen.dart';
import 'package:nutri_tracker/features/dashboard/dashboard_screen.dart';
import 'package:nutri_tracker/features/nutrition/nutrition_home_screen.dart';
import 'package:nutri_tracker/features/progress/progress_screen.dart';
import 'package:nutri_tracker/features/workout/workout_hub_screen.dart';
import 'package:nutri_tracker/routes/app_routes.dart';

class AllInOneShell extends StatefulWidget {
  const AllInOneShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<AllInOneShell> createState() => _AllInOneShellState();
}

class _AllInOneShellState extends State<AllInOneShell> {
  late int _index;

  static const _routes = [
    AppRoutes.dashboard,
    AppRoutes.nutrition,
    AppRoutes.workoutHub,
    AppRoutes.progress,
    AppRoutes.aiChat,
  ];

  final _screens = const [
    DashboardScreen(),
    NutritionHomeScreen(),
    WorkoutHubScreen(),
    ProgressScreen(showAppBar: false),
    AIAssistantScreen(showAppBar: false),
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, _screens.length - 1);
  }

  @override
  void didUpdateWidget(covariant AllInOneShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _index = widget.initialIndex.clamp(0, _screens.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) {
          setState(() => _index = index);
          context.go(_routes[index]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu_rounded),
            label: 'Nutrition',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center_rounded),
            label: 'Workouts',
          ),
          NavigationDestination(
            icon: Icon(Icons.monitor_heart_outlined),
            selectedIcon: Icon(Icons.monitor_heart_rounded),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome_rounded),
            label: 'Coach',
          ),
        ],
      ),
    );
  }
}
