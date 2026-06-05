import 'package:nutri_tracker/models/workout_entry.dart';

abstract interface class IWorkoutRepository {
  Future<void> logWorkout(String uid, ExerciseEntry entry);

  Stream<List<ExerciseEntry>> watchTodayWorkouts(String uid);

  Future<int> getTodayCaloriesBurned(String uid);
}
