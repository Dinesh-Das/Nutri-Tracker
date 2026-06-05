import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_tracker/models/meal_entry.dart';
import 'package:nutri_tracker/repositories/i_calorie_repository.dart';
import 'package:nutri_tracker/services/calorie_service.dart';

final calorieRepositoryProvider = Provider<ICalorieRepository>((ref) {
  return FirestoreCalorieRepository(FirebaseFirestore.instance);
});

class FirestoreCalorieRepository implements ICalorieRepository {
  FirestoreCalorieRepository(FirebaseFirestore firestore)
      : _service = CalorieService(firestore: firestore);

  final CalorieService _service;

  @override
  Stream<DailyCalorieLog> watchDailyLog(String uid, DateTime date) {
    return _service.watchDailyLog(uid, date);
  }

  @override
  Future<DailyCalorieLog> getDailyLog(String uid, DateTime date) {
    return _service.getDailyLog(uid, date);
  }

  @override
  Future<List<DailyCalorieLog>> getDailyLogsInRange(
    String uid, {
    required DateTime start,
    required DateTime end,
  }) {
    return _service.getDailyLogsInRange(uid, start: start, end: end);
  }

  @override
  Future<int> getLogStreak(String uid) {
    return _service.getLogStreak(uid);
  }

  @override
  Future<void> addMealEntry(String uid, DateTime date, MealEntry entry) {
    return _service.addMealEntry(uid, date, entry);
  }

  @override
  Future<void> updateWaterIntake(String uid, DateTime date, int cups) {
    return _service.updateWaterIntake(uid, date, cups);
  }
}
