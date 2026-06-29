import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutri_tracker/models/daily_health_summary.dart';
import 'package:nutri_tracker/repositories/nutrition_repository.dart';
import 'package:nutri_tracker/repositories/workout_repository.dart';
import 'package:nutri_tracker/services/firestore_service.dart';

class DailySummaryService {
  DailySummaryService({
    FirebaseFirestore? firestore,
    NutritionRepository? nutritionRepository,
    WorkoutRepository? workoutRepository,
    FirestoreService? firestoreService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _nutritionRepository = nutritionRepository ?? NutritionRepository(),
        _workoutRepository = workoutRepository ?? WorkoutRepository(),
        _firestoreService = firestoreService ?? FirestoreService();

  final FirebaseFirestore _firestore;
  final NutritionRepository _nutritionRepository;
  final WorkoutRepository _workoutRepository;
  final FirestoreService _firestoreService;

  Stream<DailyHealthSummary> watchSummary(String uid, DateTime date) {
    final key = _nutritionRepository.dateKey(date);
    return _firestore
        .collection('daily_summaries')
        .doc(uid)
        .collection('daily')
        .doc(key)
        .snapshots()
        .map((doc) => DailyHealthSummary.fromMap(key, doc.data()));
  }

  Future<DailyHealthSummary> rebuildSummary(String uid, DateTime date) async {
    final key = _nutritionRepository.dateKey(date);
    final nutrition = await _nutritionRepository.getDailyLog(uid, date);
    final workouts = await _workoutRepository.getSessionsInRange(
      uid,
      start: DateTime(date.year, date.month, date.day),
      end: DateTime(date.year, date.month, date.day, 23, 59, 59),
    );
    final completed =
        workouts.where((session) => session.status == 'completed').toList();
    final user = await _firestoreService.getUser(uid);
    final burned = nutrition.caloriesBurned +
        completed.fold<int>(
          0,
          (total, session) => total + session.caloriesBurned,
        );
    final summary = DailyHealthSummary(
      uid: uid,
      dateKey: key,
      caloriesConsumed: nutrition.totalCalories,
      caloriesBurned: burned,
      netCalories: nutrition.totalCalories - burned,
      protein: nutrition.totalProtein,
      carbs: nutrition.totalCarbs,
      fat: nutrition.totalFat,
      fiber: nutrition.totalFiber,
      waterIntakeMl: nutrition.waterIntakeMl,
      workoutMinutes: completed.fold<int>(
        0,
        (total, session) => total + session.totalDurationMinutes,
      ),
      workoutsCompleted: completed.length,
      weightKg: double.tryParse(user.weight ?? ''),
      bmi: user.bmi,
      updatedAt: DateTime.now(),
    );
    await _firestore
        .collection('daily_summaries')
        .doc(uid)
        .collection('daily')
        .doc(key)
        .set(summary.toMap(), SetOptions(merge: true));
    return summary;
  }
}
