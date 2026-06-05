import 'package:nutri_tracker/models/meal_entry.dart';

abstract interface class ICalorieRepository {
  Stream<DailyCalorieLog> watchDailyLog(String uid, DateTime date);

  Future<DailyCalorieLog> getDailyLog(String uid, DateTime date);

  Future<List<DailyCalorieLog>> getDailyLogsInRange(
    String uid, {
    required DateTime start,
    required DateTime end,
  });

  Future<int> getLogStreak(String uid);

  Future<void> addMealEntry(String uid, DateTime date, MealEntry entry);

  Future<void> updateWaterIntake(String uid, DateTime date, int cups);
}
