import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_tracker/admin/admin_home.dart';
import 'package:nutri_tracker/bmi/screens/calculator_screen.dart';
import 'package:nutri_tracker/drawer/profile/edit_profile.dart';
import 'package:nutri_tracker/drawer/profile/view_profile.dart';
import 'package:nutri_tracker/drawer/settings/settings.dart';
import 'package:nutri_tracker/features/ai/ai_assistant_screen.dart';
import 'package:nutri_tracker/features/calories/barcode_scanner_screen.dart';
import 'package:nutri_tracker/features/calories/calorie_log_screen.dart';
import 'package:nutri_tracker/features/calories/nutrition_label_scanner.dart';
import 'package:nutri_tracker/features/calories/photo_meal_screen.dart';
import 'package:nutri_tracker/features/onboarding/onboarding_screen.dart';
import 'package:nutri_tracker/features/progress/achievements_screen.dart';
import 'package:nutri_tracker/features/progress/progress_screen.dart';
import 'package:nutri_tracker/features/recipes/recipe_detail_screen.dart';
import 'package:nutri_tracker/features/recipes/recipe_screen.dart';
import 'package:nutri_tracker/features/workout/workout_log_screen.dart';
import 'package:nutri_tracker/homepage/bottom_navigation.dart';
import 'package:nutri_tracker/login_screens/login_page.dart';
import 'package:nutri_tracker/login_screens/register_page.dart';
import 'package:nutri_tracker/models/indian_recipe.dart';
import 'package:nutri_tracker/routes/app_routes.dart';
import 'package:nutri_tracker/splash.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final publicRoutes = {
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.onboarding,
      };
      if (user == null && !publicRoutes.contains(state.matchedLocation)) {
        return AppRoutes.login;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const Splash(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const BottomNavigation(),
      ),
      GoRoute(
        path: AppRoutes.bmiCalculator,
        builder: (context, state) => const CalculatorScreen(),
      ),
      GoRoute(
        path: AppRoutes.calorieLog,
        builder: (context, state) => const CalorieLogScreen(),
      ),
      GoRoute(
        path: AppRoutes.barcodeScanner,
        builder: (context, state) => const BarcodeScannerScreen(),
      ),
      GoRoute(
        path: AppRoutes.photoMeal,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            return PhotoMealScreen(
              date: extra['date'] as DateTime?,
              mealType: extra['mealType'] as String? ?? 'snack',
            );
          }
          return const PhotoMealScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.nutritionLabelScanner,
        builder: (context, state) => NutritionLabelScanner(
          mealType: state.extra is String ? state.extra as String : 'snack',
        ),
      ),
      GoRoute(
        path: AppRoutes.recipes,
        builder: (context, state) => const RecipeScreen(),
      ),
      GoRoute(
        path: AppRoutes.recipeDetail,
        builder: (context, state) {
          final recipe = state.extra;
          if (recipe is IndianRecipe) {
            return RecipeDetailScreen(recipe: recipe);
          }
          return const RouteErrorScreen(
            title: 'Recipe unavailable',
            message: 'Open recipes again and choose a recipe.',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.progress,
        builder: (context, state) => const ProgressScreen(),
      ),
      GoRoute(
        path: AppRoutes.achievements,
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiChat,
        builder: (context, state) => AIAssistantScreen(
          initialPrompt: state.extra is String ? state.extra as String : null,
        ),
      ),
      GoRoute(
        path: AppRoutes.workoutLog,
        builder: (context, state) => const WorkoutLogScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ViewProfile(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfile(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.admin,
        builder: (context, state) => const AdminPage(),
      ),
    ],
    errorBuilder: (context, state) => RouteErrorScreen(
      title: 'Page not found',
      message: state.uri.toString(),
    ),
  );
});

class RouteErrorScreen extends StatelessWidget {
  const RouteErrorScreen({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Go home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
