import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nutri_tracker/models/exercise.dart';
import 'package:nutri_tracker/models/workout_program.dart';
import 'package:nutri_tracker/models/workout_session.dart';

class WorkoutRepository {
  WorkoutRepository({FirebaseFirestore? firestore, AssetBundle? bundle})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _bundle = bundle ?? rootBundle;

  final FirebaseFirestore _firestore;
  final AssetBundle _bundle;

  String dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  Future<List<Exercise>> loadExercises() async {
    final raw = await _bundle.loadString('assets/data/exercises.json');
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map>()
        .map((item) => Exercise.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<WorkoutProgram>> loadPrograms() async {
    final raw = await _bundle.loadString('assets/data/workout_programs.json');
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map>()
        .map((item) => WorkoutProgram.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  Stream<List<WorkoutSession>> watchTodaySessions(String uid) {
    return watchSessionsForDate(uid, DateTime.now());
  }

  Stream<List<WorkoutSession>> watchSessionsForDate(String uid, DateTime date) {
    final key = dateKey(date);
    return _sessions(uid)
        .where('dateKey', isEqualTo: key)
        .snapshots()
        .map(_sessionsFromSnapshot);
  }

  Future<List<WorkoutSession>> getSessionsInRange(
    String uid, {
    required DateTime start,
    required DateTime end,
  }) async {
    final startKey = dateKey(start);
    final endKey = dateKey(end);
    final snapshot = await _sessions(uid)
        .where('dateKey', isGreaterThanOrEqualTo: startKey)
        .where('dateKey', isLessThanOrEqualTo: endKey)
        .get();
    return _sessionsFromSnapshot(snapshot);
  }

  Future<WorkoutSession> saveSession(WorkoutSession session) async {
    final ref = session.id.isEmpty
        ? _sessions(session.uid).doc()
        : _sessions(session.uid).doc(session.id);
    final saved = session.copyWith(id: ref.id);
    final dailyRef = _firestore
        .collection('workout_logs')
        .doc(session.uid)
        .collection('daily')
        .doc(session.dateKey)
        .collection('sessions')
        .doc(ref.id);
    final batch = _firestore.batch();
    batch.set(ref, saved.toMap(), SetOptions(merge: true));
    batch.set(dailyRef, saved.toMap(), SetOptions(merge: true));
    if (saved.status == 'completed') {
      batch.set(
        _firestore
            .collection('calorie_logs')
            .doc(saved.uid)
            .collection('daily')
            .doc(saved.dateKey),
        {
          'uid': saved.uid,
          'date': saved.dateKey,
          'caloriesBurned': FieldValue.increment(saved.caloriesBurned),
          'netCalories': FieldValue.increment(-saved.caloriesBurned),
          'workoutMinutes': FieldValue.increment(saved.totalDurationMinutes),
          'workoutsCompleted': FieldValue.increment(1),
          'updatedAt': Timestamp.now(),
        },
        SetOptions(merge: true),
      );
    }
    await batch.commit();
    return saved;
  }

  Future<int> getWorkoutStreak(String uid) async {
    final since = DateTime.now().subtract(const Duration(days: 60));
    final sessions = await getSessionsInRange(
      uid,
      start: since,
      end: DateTime.now(),
    );
    final completedDates = sessions
        .where((session) => session.status == 'completed')
        .map((session) => session.dateKey)
        .toSet();
    var streak = 0;
    var cursor = DateTime.now();
    while (completedDates.contains(dateKey(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  CollectionReference<Map<String, dynamic>> _sessions(String uid) {
    return _firestore
        .collection('workout_logs')
        .doc(uid)
        .collection('sessions');
  }

  List<WorkoutSession> _sessionsFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final sessions = snapshot.docs
        .map((doc) => WorkoutSession.fromMap(doc.id, doc.data()))
        .toList();
    sessions.sort((a, b) => b.date.compareTo(a.date));
    return sessions;
  }
}
