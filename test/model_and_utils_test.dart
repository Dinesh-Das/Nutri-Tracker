import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_tracker/data/workout_library.dart';
import 'package:nutri_tracker/database/user_model.dart';
import 'package:nutri_tracker/models/daily_health_summary.dart';
import 'package:nutri_tracker/models/exercise.dart';
import 'package:nutri_tracker/models/food_item.dart';
import 'package:nutri_tracker/models/indian_recipe.dart';
import 'package:nutri_tracker/models/meal_entry.dart';
import 'package:nutri_tracker/models/user_goal.dart';
import 'package:nutri_tracker/models/workout_entry.dart';
import 'package:nutri_tracker/models/workout_program.dart';
import 'package:nutri_tracker/models/workout_session.dart';
import 'package:nutri_tracker/utils/health_utils.dart';

void main() {
  group('health utils', () {
    test('calculates BMI and category boundaries', () {
      final bmi = calculateBmi(70, 175);

      expect(bmi, closeTo(22.86, 0.01));
      expect(getBmiCategory(18.4), 'Underweight');
      expect(getBmiCategory(18.5), 'Normal');
      expect(getBmiCategory(25), 'Overweight');
      expect(getBmiCategory(30), 'Obese');
    });

    test('calculates BMR with the app formulas', () {
      expect(
        calculateBmr(gender: 'Male', weightKg: 70, heightCm: 175, age: 30),
        closeTo(1695.67, 0.01),
      );
      expect(activityMultiplier('moderately_active'), 1.55);
      expect(activityMultiplier(null), 1.2);
    });

    test('estimates exercise calories with MET values', () {
      expect(
        estimateCaloriesBurned(
          exercise: 'running',
          durationMinutes: 30,
          weightKg: 70,
        ),
        closeTo(360, 20),
      );
    });

    test('calculates calorie goal and macro targets', () {
      final calories = calculateCalorieGoal(
        gender: 'Female',
        weightKg: 65,
        heightCm: 165,
        age: 28,
        activityLevel: 'moderately_active',
        goalType: 'lose_weight',
      );
      final macros = calculateMacroTargets(
        calorieGoal: calories,
        goalType: 'lose_weight',
        weightKg: 65,
      );

      expect(calories, greaterThan(1200));
      expect(macros.proteinGoalG, greaterThanOrEqualTo(78));
      expect(macros.carbsGoalG, greaterThan(0));
      expect(macros.fatGoalG, greaterThan(0));
    });
  });

  group('models', () {
    test('UserModel.toMap omits protected and null fields', () {
      final map = UserModel(
        uid: 'uid-1',
        email: 'user@example.com',
        isAdmin: true,
      ).toMap();

      expect(map['uid'], 'uid-1');
      expect(map['email'], 'user@example.com');
      expect(map.containsKey('isAdmin'), isFalse);
      expect(map.containsValue(null), isFalse);
    });

    test('UserModel.fromMap parses bmi and bmr as doubles', () {
      final model = UserModel.fromMap({'bmi': 22.5, 'bmr': 1800});

      expect(model.bmi, 22.5);
      expect(model.bmr, 1800.0);
    });

    test('UserModel.fromMap keeps legacy string bmi backward-compatible', () {
      final model = UserModel.fromMap({'bmi': '22.5', 'bmr': '1800'});

      expect(model.bmi, 22.5);
      expect(model.bmr, 1800.0);
    });

    test('MealEntry serializes and parses Firestore maps', () {
      final entry = MealEntry(
        id: 'meal-1',
        uid: 'uid-1',
        dateKey: '2026-06-29',
        source: 'search',
        mealType: 'lunch',
        foodName: 'Rajma Chawal',
        calories: 450,
        protein: 16,
        carbs: 70,
        fat: 9,
        quantity: 250,
        unit: 'grams',
      );

      final parsed = MealEntry.fromMap(entry.toMap());

      expect(parsed.mealType, 'lunch');
      expect(parsed.foodName, 'Rajma Chawal');
      expect(parsed.calories, 450);
      expect(parsed.quantity, 250);
      expect(parsed.source, 'search');
      expect(parsed.dateKey, '2026-06-29');
      expect(parsed.fiber, 0);
    });

    test('FoodItem serializes and parses Firestore maps', () {
      final item = FoodItem(
        id: 'food-1',
        uid: 'uid-1',
        name: 'Paneer Bhurji',
        caloriesPer100g: 220,
        proteinPer100g: 16,
        carbsPer100g: 8,
        fatPer100g: 14,
        dietType: 'vegetarian',
      );

      final parsed = FoodItem.fromMap(item.id, item.toMap());

      expect(parsed.name, 'Paneer Bhurji');
      expect(parsed.caloriesPer100g, 220);
      expect(parsed.isCustom, isFalse);
    });

    test('Exercise parses local seed shape', () {
      final exercise = Exercise.fromMap({
        'id': 'squats',
        'name': 'Squats',
        'category': 'strength',
        'primaryMuscles': ['quadriceps', 'glutes'],
        'equipment': 'none',
        'level': 'beginner',
        'instructions': ['Stand', 'Squat'],
        'defaultSets': 3,
        'defaultReps': 15,
        'metValue': 5.0,
      });

      expect(exercise.id, 'squats');
      expect(exercise.primaryMuscles, contains('glutes'));
      expect(exercise.toMap()['metValue'], 5.0);
    });

    test('WorkoutProgram serializes and parses days', () {
      const program = WorkoutProgram(
        id: 'p1',
        title: 'Starter',
        description: 'Home plan',
        goal: 'improve_fitness',
        level: 'beginner',
        durationWeeks: 1,
        daysPerWeek: 3,
        estimatedMinutesPerDay: 20,
        equipment: 'none',
        workoutDays: [
          WorkoutProgramDay(
            day: 1,
            title: 'Day 1',
            exerciseIds: ['squats', 'plank'],
          ),
        ],
      );

      final parsed = WorkoutProgram.fromMap(program.toMap());

      expect(parsed.title, 'Starter');
      expect(parsed.workoutDays.single.exerciseIds, contains('plank'));
    });

    test('WorkoutSession serializes and parses exercise logs', () {
      final session = WorkoutSession(
        id: 's1',
        uid: 'uid-1',
        title: 'Full Body',
        date: DateTime(2026, 6, 29),
        dateKey: '2026-06-29',
        status: 'completed',
        totalDurationMinutes: 25,
        caloriesBurned: 160,
        exercises: [
          WorkoutExerciseLog(
            exerciseId: 'plank',
            name: 'Plank',
            durationSeconds: 30,
            completed: true,
          ),
        ],
      );

      final parsed = WorkoutSession.fromMap(session.id, session.toMap());

      expect(parsed.uid, 'uid-1');
      expect(parsed.exercises.single.name, 'Plank');
      expect(parsed.status, 'completed');
    });

    test('WorkoutPlan library entries have positive calorie estimates', () {
      for (final plan in kWorkoutLibrary) {
        expect(plan.estimatedCalories, greaterThan(0), reason: plan.id);
      }
    });

    test('ExerciseEntry serializes and parses sets and reps', () {
      final timestamp = DateTime(2026, 6, 29, 18, 30);
      final entry = ExerciseEntry(
        id: 'exercise-1',
        name: 'Push-ups',
        category: 'strength',
        durationMinutes: 20,
        caloriesBurned: 150,
        timestamp: timestamp,
        notes: 'Felt strong',
        sets: 4,
        reps: 12,
        weightKg: 5,
      );

      final parsed = ExerciseEntry.fromMap(entry.id, entry.toMap());

      expect(parsed.id, 'exercise-1');
      expect(parsed.name, 'Push-ups');
      expect(parsed.category, 'strength');
      expect(parsed.durationMinutes, 20);
      expect(parsed.caloriesBurned, 150);
      expect(parsed.timestamp, timestamp);
      expect(parsed.notes, 'Felt strong');
      expect(parsed.sets, 4);
      expect(parsed.reps, 12);
      expect(parsed.weightKg, 5);
    });

    test('UserGoal serializes and parses Firestore maps', () {
      final goal = UserGoal(
        id: 'g1',
        uid: 'uid-1',
        goalType: 'gain_muscle',
        dailyCalorieGoal: 2400,
        proteinGoalG: 140,
        carbsGoalG: 280,
        fatGoalG: 75,
        waterGoalMl: 3000,
        stepGoal: 9000,
        workoutsPerWeek: 5,
        preferredWorkoutDays: const ['Mon', 'Wed'],
        workoutDurationMinutes: 45,
        fitnessLevel: 'intermediate',
        equipment: 'dumbbells',
      );

      final parsed = UserGoal.fromMap(goal.id, goal.toMap());

      expect(parsed.goalType, 'gain_muscle');
      expect(parsed.preferredWorkoutDays, contains('Wed'));
      expect(parsed.isActive, isTrue);
    });

    test('DailyHealthSummary serializes and parses aggregate data', () {
      const summary = DailyHealthSummary(
        uid: 'uid-1',
        dateKey: '2026-06-29',
        caloriesConsumed: 1800,
        caloriesBurned: 300,
        netCalories: 1500,
        protein: 95,
        waterIntakeMl: 2500,
        workoutMinutes: 35,
        workoutsCompleted: 1,
      );

      final parsed =
          DailyHealthSummary.fromMap(summary.dateKey, summary.toMap());

      expect(parsed.netCalories, 1500);
      expect(parsed.workoutsCompleted, 1);
    });

    test('IndianRecipe parses TheMealDB ingredients', () {
      final recipe = IndianRecipe.fromJson({
        'idMeal': '52807',
        'strMeal': 'Baingan Bharta',
        'strCategory': 'Vegetarian',
        'strArea': 'Indian',
        'strInstructions': 'Roast, mash, and simmer.',
        'strMealThumb': 'https://example.com/baingan.jpg',
        'strYoutube': 'https://youtube.com/watch?v=example',
        'strIngredient1': 'Aubergine',
        'strMeasure1': '1 large',
        'strIngredient2': 'Tomato',
        'strMeasure2': '2',
        'strIngredient3': '',
      });

      expect(recipe.id, '52807');
      expect(recipe.name, 'Baingan Bharta');
      expect(recipe.ingredients, hasLength(2));
      expect(recipe.ingredients.first.name, 'Aubergine');
    });
  });
}
