import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutri_tracker/models/achievement.dart';
import 'package:nutri_tracker/models/workout_entry.dart';
import 'package:nutri_tracker/services/achievement_service.dart';

class WorkoutService {
  WorkoutService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> logWorkout(String uid, ExerciseEntry entry) async {
    final collection =
        _firestore.collection('workout_logs').doc(uid).collection('entries');
    final ref = entry.id.isEmpty ? collection.doc() : collection.doc(entry.id);
    await ref.set({
      ...entry.toMap(),
      'uid': uid,
    }, SetOptions(merge: true));
    try {
      await AchievementService().checkAndAward(
        uid,
        AchievementType.firstWorkout,
      );
      final count = (await collection.count().get()).count ?? 0;
      if (count >= 50) {
        await AchievementService().checkAndAward(
          uid,
          AchievementType.workouts50,
        );
      } else if (count >= 10) {
        await AchievementService().checkAndAward(
          uid,
          AchievementType.workouts10,
        );
      }
    } catch (_) {}
  }

  Stream<List<ExerciseEntry>> watchTodayWorkouts(String uid) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return _firestore
        .collection('workout_logs')
        .doc(uid)
        .collection('entries')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('timestamp', isLessThan: Timestamp.fromDate(end))
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExerciseEntry.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<int> getTodayCaloriesBurned(String uid) async {
    final workouts = await watchTodayWorkouts(uid).first;
    return workouts.fold<int>(
      0,
      (total, entry) => total + entry.caloriesBurned,
    );
  }
}
