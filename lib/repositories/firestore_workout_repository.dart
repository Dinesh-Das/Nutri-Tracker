import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_tracker/models/workout_entry.dart';
import 'package:nutri_tracker/repositories/i_workout_repository.dart';
import 'package:nutri_tracker/services/workout_service.dart';

final workoutRepositoryProvider = Provider<IWorkoutRepository>((ref) {
  return FirestoreWorkoutRepository(FirebaseFirestore.instance);
});

class FirestoreWorkoutRepository implements IWorkoutRepository {
  FirestoreWorkoutRepository(FirebaseFirestore firestore)
      : _service = WorkoutService(firestore: firestore);

  final WorkoutService _service;

  @override
  Future<void> logWorkout(String uid, ExerciseEntry entry) {
    return _service.logWorkout(uid, entry);
  }

  @override
  Stream<List<ExerciseEntry>> watchTodayWorkouts(String uid) {
    return _service.watchTodayWorkouts(uid);
  }

  @override
  Future<int> getTodayCaloriesBurned(String uid) {
    return _service.getTodayCaloriesBurned(uid);
  }
}
