import 'package:nutri_tracker/models/workout_entry.dart';

abstract interface class IWorkoutRepository {
  Future<void> logWorkout(String uid, ExerciseEntry entry);

  Stream<List<ExerciseEntry>> watchTodayWorkouts(String uid);

  Stream<List<ExerciseEntry>> watchWorkoutsInRange(
    String uid, {
    required DateTime start,
    DateTime? end,
  });

  Future<int> getTodayCaloriesBurned(String uid);

  Future<int> getWeeklyWorkoutCount(String uid);
}
