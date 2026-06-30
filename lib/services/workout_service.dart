import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutri_tracker/models/achievement.dart';
import 'package:nutri_tracker/models/workout_entry.dart';
import 'package:nutri_tracker/models/workout_session.dart';
import 'package:nutri_tracker/repositories/workout_repository.dart';
import 'package:nutri_tracker/services/achievement_service.dart';
import 'package:nutri_tracker/services/daily_summary_service.dart';

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
    final workoutRepository = WorkoutRepository(firestore: _firestore);
    await workoutRepository.saveSession(
      WorkoutSession(
        id: ref.id,
        uid: uid,
        title: entry.name,
        date: entry.timestamp,
        dateKey: workoutRepository.dateKey(entry.timestamp),
        startedAt: entry.timestamp,
        completedAt: entry.timestamp,
        status: 'completed',
        totalDurationMinutes: entry.durationMinutes,
        caloriesBurned: entry.caloriesBurned,
        exercises: [
          WorkoutExerciseLog(
            exerciseId: entry.name.toLowerCase().replaceAll(' ', '_'),
            name: entry.name,
            sets: entry.sets,
            reps: entry.reps,
            durationSeconds: entry.durationMinutes * 60,
            completed: true,
            caloriesBurned: entry.caloriesBurned,
            notes: entry.notes ?? '',
          ),
        ],
        notes: entry.notes ?? '',
        source: 'manual',
      ),
    );
    await DailySummaryService(firestore: _firestore)
        .rebuildSummary(uid, entry.timestamp);
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
