import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutri_tracker/models/user_goal.dart';

class GoalRepository {
  GoalRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<UserGoal?> watchActiveGoal(String uid) {
    return _goals(uid)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return UserGoal.fromMap(doc.id, doc.data());
    });
  }

  Future<UserGoal?> getActiveGoal(String uid) async {
    final snapshot =
        await _goals(uid).where('isActive', isEqualTo: true).limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return UserGoal.fromMap(doc.id, doc.data());
  }

  Future<UserGoal> saveGoal(UserGoal goal) async {
    final ref = goal.id.isEmpty
        ? _goals(goal.uid).doc()
        : _goals(goal.uid).doc(goal.id);
    final existingActive =
        await _goals(goal.uid).where('isActive', isEqualTo: true).get();
    final batch = _firestore.batch();
    for (final doc in existingActive.docs) {
      if (doc.id != ref.id) {
        batch.set(doc.reference, {'isActive': false}, SetOptions(merge: true));
      }
    }
    final saved = goal.copyWith(
      id: ref.id,
      updatedAt: DateTime.now(),
      isActive: true,
    );
    batch.set(ref, saved.toMap(), SetOptions(merge: true));
    batch.set(
      _firestore.collection('user_details').doc(goal.uid),
      {
        'uid': goal.uid,
        'dailyCalorieGoal': goal.dailyCalorieGoal,
        'targetWeight': goal.targetWeightKg,
        'weightGoal': goal.goalType,
        'fitnessLevel': goal.fitnessLevel,
        'equipment': goal.equipment,
        'workoutsPerWeek': goal.workoutsPerWeek,
        'workoutDurationMinutes': goal.workoutDurationMinutes,
        'preferredWorkoutDays': goal.preferredWorkoutDays,
        'dietaryPreference': goal.dietPreference,
        'allergies': goal.allergies,
        'updatedAt': Timestamp.now(),
      },
      SetOptions(merge: true),
    );
    await batch.commit();
    return saved;
  }

  CollectionReference<Map<String, dynamic>> _goals(String uid) {
    return _firestore.collection('user_goals').doc(uid).collection('goals');
  }
}
