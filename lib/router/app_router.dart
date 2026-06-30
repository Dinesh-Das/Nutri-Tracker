import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_tracker/admin/admin_home.dart';
import 'package:nutri_tracker/bmi/screens/calculator_screen.dart';
import 'package:nutri_tracker/bmi/screens/result_screen.dart';
import 'package:nutri_tracker/drawer/profile/edit_profile.dart';
import 'package:nutri_tracker/drawer/profile/view_profile.dart';
import 'package:nutri_tracker/drawer/settings/settings.dart';
import 'package:nutri_tracker/features/ai/ai_assistant_screen.dart';
import 'package:nutri_tracker/features/ai/meal_plan_screen.dart';
import 'package:nutri_tracker/features/ai/nutrition_estimator.dart';
import 'package:nutri_tracker/features/ai/workout_plan_screen.dart';
import 'package:nutri_tracker/features/calories/barcode_scanner_screen.dart';
import 'package:nutri_tracker/features/calories/nutrition_label_scanner.dart';
import 'package:nutri_tracker/features/calories/photo_meal_screen.dart';
import 'package:nutri_tracker/features/goals/goals_screen.dart';
import 'package:nutri_tracker/features/home/all_in_one_shell.dart';
import 'package:nutri_tracker/features/nutrition/add_meal_screen.dart';
import 'package:nutri_tracker/features/nutrition/custom_food_screen.dart';
import 'package:nutri_tracker/features/nutrition/meal_detail_screen.dart';
import 'package:nutri_tracker/features/onboarding/onboarding_screen.dart';
import 'package:nutri_tracker/features/progress/achievements_screen.dart';
import 'package:nutri_tracker/features/recipes/recipe_detail_screen.dart';
import 'package:nutri_tracker/features/recipes/recipe_screen.dart';
import 'package:nutri_tracker/features/workout/home_workout_screen.dart';
import 'package:nutri_tracker/features/workout/workout_log_screen.dart';
import 'package:nutri_tracker/features/workouts/active_workout_session_screen.dart';
import 'package:nutri_tracker/features/workouts/exercise_detail_screen.dart';
import 'package:nutri_tracker/features/workouts/exercise_library_screen.dart';
import 'package:nutri_tracker/features/workouts/workout_history_screen.dart';
import 'package:nutri_tracker/features/workouts/workout_program_detail_screen.dart';
import 'package:nutri_tracker/features/workouts/workout_program_list_screen.dart';
import 'package:nutri_tracker/login_screens/login_page.dart';
import 'package:nutri_tracker/login_screens/register_page.dart';
import 'package:nutri_tracker/models/exercise.dart';
import 'package:nutri_tracker/models/indian_recipe.dart';
import 'package:nutri_tracker/models/meal_entry.dart';
import 'package:nutri_tracker/models/workout_program.dart';
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
        builder: (context, state) => const AllInOneShell(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const AllInOneShell(),
      ),
      GoRoute(
        path: AppRoutes.bmiCalculator,
        builder: (context, state) => const CalculatorScreen(),
      ),
      GoRoute(
        path: AppRoutes.bmiResult,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, String>) {
            return ResultsPage(
              interpretation: extra['interpretation'] ?? '',
              bmiResult: extra['bmiResult'] ?? '',
              resultText: extra['resultText'] ?? '',
            );
          }
          return const RouteErrorScreen(
            title: 'BMI result unavailable',
            message: 'Calculate BMI again to see your result.',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.calorieLog,
        builder: (context, state) => const AllInOneShell(initialIndex: 1),
      ),
      GoRoute(
        path: AppRoutes.nutrition,
        builder: (context, state) => const AllInOneShell(initialIndex: 1),
      ),
      GoRoute(
        path: AppRoutes.addMeal,
        builder: (context, state) => const AddMealScreen(),
      ),
      GoRoute(
        path: AppRoutes.nutritionAdd,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            return AddMealScreen(
              date: extra['date'] as DateTime?,
              initialMealType: extra['mealType'] as String? ?? 'snack',
            );
          }
          return const AddMealScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.nutritionMealDetail,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic> &&
              extra['meal'] is MealEntry &&
              extra['date'] is DateTime) {
            return MealDetailScreen(
              meal: extra['meal'] as MealEntry,
              date: extra['date'] as DateTime,
            );
          }
          return const RouteErrorScreen(
            title: 'Meal unavailable',
            message: 'Open Nutrition and choose a meal again.',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.mealPlan,
        builder: (context, state) => const MealPlanScreen(),
      ),
      GoRoute(
        path: AppRoutes.nutritionEstimator,
        builder: (context, state) => const NutritionEstimatorScreen(),
      ),
      GoRoute(
        path: AppRoutes.customFood,
        builder: (context, state) => const CustomFoodScreen(),
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
        builder: (context, state) => const AllInOneShell(initialIndex: 3),
      ),
      GoRoute(
        path: AppRoutes.achievements,
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiChat,
        builder: (context, state) => const AllInOneShell(initialIndex: 4),
      ),
      GoRoute(
        path: AppRoutes.aiCoach,
        builder: (context, state) => AIAssistantScreen(
          initialPrompt: state.extra is String ? state.extra as String : null,
        ),
      ),
      GoRoute(
        path: AppRoutes.aiWorkoutPlan,
        builder: (context, state) => const AIWorkoutPlanScreen(),
      ),
      GoRoute(
        path: AppRoutes.goals,
        builder: (context, state) => const GoalsScreen(),
      ),
      GoRoute(
        path: AppRoutes.workoutHub,
        builder: (context, state) => const AllInOneShell(initialIndex: 2),
      ),
      GoRoute(
        path: AppRoutes.workoutLog,
        builder: (context, state) => const WorkoutLogScreen(),
      ),
      GoRoute(
        path: AppRoutes.workouts,
        builder: (context, state) => const AllInOneShell(initialIndex: 2),
      ),
      GoRoute(
        path: AppRoutes.homeWorkout,
        builder: (context, state) => const HomeWorkoutScreen(),
      ),
      GoRoute(
        path: AppRoutes.workoutLibrary,
        builder: (context, state) => const ExerciseLibraryScreen(),
      ),
      GoRoute(
        path: AppRoutes.workoutPrograms,
        builder: (context, state) => const WorkoutProgramListScreen(),
      ),
      GoRoute(
        path: AppRoutes.activeWorkoutSession,
        builder: (context, state) => ActiveWorkoutSessionScreen(
          seed: state.extra,
        ),
      ),
      GoRoute(
        path: AppRoutes.workoutHistory,
        builder: (context, state) => const WorkoutHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.workoutDetail,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is WorkoutProgram) {
            return WorkoutProgramDetailScreen(program: extra);
          }
          return const RouteErrorScreen(
            title: 'Program unavailable',
            message: 'Open workout programs and choose a plan again.',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.exerciseDetail,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Exercise) {
            return ExerciseDetailScreen(exercise: extra);
          }
          return const RouteErrorScreen(
            title: 'Exercise unavailable',
            message: 'Open the exercise library and choose an exercise again.',
          );
        },
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
                onPressed: () => context.go(AppRoutes.dashboard),
                child: const Text('Go home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
