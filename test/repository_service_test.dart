import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_tracker/models/meal_entry.dart';
import 'package:nutri_tracker/models/user_goal.dart';
import 'package:nutri_tracker/models/workout_session.dart';
import 'package:nutri_tracker/repositories/goal_repository.dart';
import 'package:nutri_tracker/repositories/nutrition_repository.dart';
import 'package:nutri_tracker/repositories/workout_repository.dart';
import 'package:nutri_tracker/services/daily_summary_service.dart';
import 'package:nutri_tracker/services/firestore_service.dart';

void main() {
  group('NutritionRepository', () {
    test('add, edit, and delete meal update daily totals', () async {
      final firestore = FakeFirebaseFirestore();
      final repository = NutritionRepository(firestore: firestore);
      const uid = 'uid-1';
      final date = DateTime(2026, 6, 30);

      final saved = await repository.addMealEntry(
        uid,
        date,
        MealEntry(
          mealType: 'lunch',
          foodName: 'Dal Rice',
          calories: 500,
          protein: 18,
          carbs: 80,
          fat: 10,
          quantity: 300,
          unit: 'grams',
        ),
      );

      var log = await repository.getDailyLog(uid, date);
      expect(log.totalCalories, 500);
      expect(log.totalProtein, 18);

      await repository.updateMealEntry(
        uid,
        date,
        saved.copyWith(calories: 650, protein: 24),
      );
      log = await repository.getDailyLog(uid, date);
      expect(log.totalCalories, 650);
      expect(log.totalProtein, 24);

      await repository.deleteMealEntry(uid, date, saved);
      log = await repository.getDailyLog(uid, date);
      expect(log.totalCalories, 0);
      expect(log.totalProtein, 0);
    });

    test('recent food normalization keeps per-100g calories correct', () async {
      final firestore = FakeFirebaseFirestore();
      final repository = NutritionRepository(firestore: firestore);
      const uid = 'uid-1';
      final date = DateTime(2026, 6, 30);

      await repository.addMealEntry(
        uid,
        date,
        MealEntry(
          mealType: 'lunch',
          foodName: 'Rajma Chawal',
          calories: 450,
          protein: 15,
          carbs: 70,
          fat: 9,
          quantity: 250,
          unit: 'grams',
        ),
      );

      final recent = await firestore
          .collection('recent_foods')
          .doc(uid)
          .collection('items')
          .doc('rajma_chawal')
          .get();
      expect(recent.data()?['caloriesPer100g'], closeTo(180, 0.01));

      final relogCalories =
          ((recent.data()?['caloriesPer100g'] as num).toDouble() * 2.5).round();
      expect(relogCalories, 450);
      expect(relogCalories, isNot(1125));
    });

    test('water update persists daily water intake', () async {
      final firestore = FakeFirebaseFirestore();
      final repository = NutritionRepository(firestore: firestore);
      const uid = 'uid-1';
      final date = DateTime(2026, 6, 30);

      await repository.updateWaterIntake(uid, date, 1750);

      final log = await repository.getDailyLog(uid, date);
      expect(log.waterIntakeMl, 1750);
    });

    test('mixed legacy array meals and document meals are both readable',
        () async {
      final firestore = FakeFirebaseFirestore();
      final repository = NutritionRepository(firestore: firestore);
      const uid = 'uid-1';
      final date = DateTime(2026, 6, 30);
      final key = repository.dateKey(date);

      await firestore
          .collection('calorie_logs')
          .doc(uid)
          .collection('daily')
          .doc(key)
          .set({
        'uid': uid,
        'date': key,
        'totalCalories': 700,
        'meals': [
          MealEntry(
            mealType: 'breakfast',
            foodName: 'Poha',
            calories: 300,
            protein: 8,
            carbs: 50,
            fat: 8,
            quantity: 1,
            unit: 'plate',
          ).toMap(),
        ],
      });

      await firestore
          .collection('calorie_logs')
          .doc(uid)
          .collection('daily')
          .doc(key)
          .collection('meals')
          .doc('doc-meal')
          .set(MealEntry(
            id: 'doc-meal',
            uid: uid,
            dateKey: key,
            mealType: 'lunch',
            foodName: 'Curd Rice',
            calories: 400,
            protein: 12,
            carbs: 68,
            fat: 8,
            quantity: 1,
            unit: 'bowl',
          ).toMap());

      final log = await repository.getDailyLog(uid, date);
      expect(log.meals.map((meal) => meal.foodName),
          containsAll(['Poha', 'Curd Rice']));
      expect(log.totalCalories, 700);
    });
  });

  group('WorkoutRepository', () {
    test('save session writes session and increments calories once', () async {
      final firestore = FakeFirebaseFirestore();
      final repository = WorkoutRepository(firestore: firestore);
      const uid = 'uid-1';
      final now = DateTime.now();

      final saved = await repository.saveSession(
        WorkoutSession(
          id: '',
          uid: uid,
          title: 'Full body',
          date: now,
          dateKey: repository.dateKey(now),
          status: 'completed',
          totalDurationMinutes: 30,
          caloriesBurned: 220,
          exercises: [
            WorkoutExerciseLog(
              exerciseId: 'squats',
              name: 'Squats',
              completed: true,
              caloriesBurned: 220,
            ),
          ],
        ),
      );

      expect(saved.id, isNotEmpty);
      await repository.saveSession(saved);

      final daily = await firestore
          .collection('calorie_logs')
          .doc(uid)
          .collection('daily')
          .doc(saved.dateKey)
          .get();
      expect(daily.data()?['caloriesBurned'], 220);
      expect(daily.data()?['workoutsCompleted'], 1);

      final sessions = await repository.getSessionsInRange(
        uid,
        start: now.subtract(const Duration(hours: 1)),
        end: now.add(const Duration(hours: 1)),
      );
      expect(sessions, hasLength(1));
    });

    test('workout streak counts completed workouts from today', () async {
      final firestore = FakeFirebaseFirestore();
      final repository = WorkoutRepository(firestore: firestore);
      const uid = 'uid-1';
      final now = DateTime.now();

      await repository.saveSession(
        WorkoutSession(
          id: '',
          uid: uid,
          title: 'Walk',
          date: now,
          dateKey: repository.dateKey(now),
          status: 'completed',
          totalDurationMinutes: 20,
          caloriesBurned: 100,
        ),
      );

      expect(await repository.getWorkoutStreak(uid), 1);
    });
  });

  group('GoalRepository', () {
    test('save active goal deactivates previous goal and mirrors user fields',
        () async {
      final firestore = FakeFirebaseFirestore();
      final repository = GoalRepository(firestore: firestore);
      const uid = 'uid-1';

      final first = await repository.saveGoal(_goal(uid, 'maintain', 2000));
      final second = await repository.saveGoal(_goal(uid, 'lose_weight', 1800));

      final oldGoal = await firestore
          .collection('user_goals')
          .doc(uid)
          .collection('goals')
          .doc(first.id)
          .get();
      final user = await firestore.collection('user_details').doc(uid).get();

      expect(oldGoal.data()?['isActive'], isFalse);
      expect(second.isActive, isTrue);
      expect(user.data()?['dailyCalorieGoal'], 1800);
      expect(user.data()?['weightGoal'], 'lose_weight');
    });
  });

  group('DailySummaryService', () {
    test('rebuild summary does not double-count workout calories', () async {
      final firestore = FakeFirebaseFirestore();
      final workoutRepository = WorkoutRepository(firestore: firestore);
      final nutritionRepository = NutritionRepository(firestore: firestore);
      const uid = 'uid-1';
      final date = DateTime.now();
      final key = nutritionRepository.dateKey(date);

      await firestore.collection('user_details').doc(uid).set({
        'uid': uid,
        'weight': '70',
        'bmi': 22.5,
      });
      await workoutRepository.saveSession(
        WorkoutSession(
          id: '',
          uid: uid,
          title: 'Workout',
          date: date,
          dateKey: key,
          status: 'completed',
          totalDurationMinutes: 25,
          caloriesBurned: 180,
        ),
      );

      final summary = await DailySummaryService(
        firestore: firestore,
        nutritionRepository: nutritionRepository,
        workoutRepository: workoutRepository,
        firestoreService: FirestoreService(firestore: firestore),
      ).rebuildSummary(uid, date);

      expect(summary.caloriesBurned, 180);
      expect(summary.workoutsCompleted, 1);
      expect(summary.workoutMinutes, 25);
    });
  });
}

UserGoal _goal(String uid, String type, int calories) {
  return UserGoal(
    id: '',
    uid: uid,
    goalType: type,
    dailyCalorieGoal: calories,
    proteinGoalG: 100,
    carbsGoalG: 220,
    fatGoalG: 60,
    waterGoalMl: 2500,
    stepGoal: 8000,
    workoutsPerWeek: 3,
    workoutDurationMinutes: 30,
    fitnessLevel: 'beginner',
    equipment: 'none',
  );
}
