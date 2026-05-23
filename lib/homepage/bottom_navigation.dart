import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/features/ai/ai_assistant_screen.dart';
import 'package:nutri_tracker/features/calories/calorie_log_screen.dart';
import 'package:nutri_tracker/features/home/home_screen.dart';
import 'package:nutri_tracker/features/progress/progress_screen.dart';
import 'package:nutri_tracker/features/recipes/recipe_screen.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  final navigationKey = GlobalKey<CurvedNavigationBarState>();
  int index = 0;
  final screens = [
    const HomeScreen(),
    const CalorieLogScreen(),
    const RecipeScreen(),
    const ProgressScreen(),
    const AIAssistantScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      const Icon(Icons.home_rounded, size: 28),
      const Icon(Icons.restaurant_menu_rounded, size: 28),
      const Icon(Icons.menu_book_rounded, size: 28),
      const Icon(Icons.bar_chart_rounded, size: 28),
      const Icon(Icons.auto_awesome_rounded, size: 28),
    ];
    return Scaffold(
      extendBody: true,
      body: screens[index],
      bottomNavigationBar: CurvedNavigationBar(
        key: navigationKey,
        color: Theme.of(context).colorScheme.surface,
        buttonBackgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        backgroundColor: Colors.transparent,
        items: items,
        height: 50,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        index: index,
        onTap: (index) => setState(() {
          this.index = index;
        }),
      ),
    );
  }
}

// ontap to change state of curved nav
// final navigationState = navigationState.currentState;
// navigationState.setPage(0);
