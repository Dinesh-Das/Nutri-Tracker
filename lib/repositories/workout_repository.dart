import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nutri_tracker/models/exercise.dart';
import 'package:nutri_tracker/models/user_workout_program.dart';
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

  Future<List<WorkoutProgram>> loadAvailablePrograms(String uid) async {
    final builtIn = await loadPrograms();
    final custom = await getCustomPrograms(uid);
    return [...custom, ...builtIn];
  }

  Future<List<WorkoutProgram>> getCustomPrograms(String uid) async {
    final snapshot = await _customPrograms(uid).get();
    return snapshot.docs
        .map((doc) => WorkoutProgram.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Stream<UserWorkoutProgram?> watchActiveProgram(String uid) {
    return _programs(uid)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return UserWorkoutProgram.fromMap(doc.id, doc.data());
    });
  }

  Future<UserWorkoutProgram?> getActiveProgram(String uid) async {
    final snapshot = await _programs(uid)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return UserWorkoutProgram.fromMap(doc.id, doc.data());
  }

  Stream<UserWorkoutProgram?> watchProgramEnrollment(
    String uid,
    String programId,
  ) {
    return _programs(uid).doc(programId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserWorkoutProgram.fromMap(doc.id, doc.data()!);
    });
  }

  Future<UserWorkoutProgram> startProgram(
    String uid,
    WorkoutProgram program,
  ) async {
    final ref = _programs(uid).doc(program.id);
    final active =
        await _programs(uid).where('status', isEqualTo: 'active').get();
    final now = DateTime.now();
    final batch = _firestore.batch();
    for (final doc in active.docs) {
      if (doc.id != program.id) {
        batch.set(
          doc.reference,
          {'status': 'paused', 'updatedAt': Timestamp.fromDate(now)},
          SetOptions(merge: true),
        );
      }
    }
    final existing = await ref.get();
    final enrollment = existing.exists
        ? UserWorkoutProgram.fromMap(ref.id, existing.data()!).copyWith(
            status: 'active',
            updatedAt: now,
          )
        : UserWorkoutProgram(
            id: ref.id,
            uid: uid,
            programId: program.id,
            title: program.title,
            currentWeek: 1,
            currentDay: _firstProgramDay(program),
            status: 'active',
            createdAt: now,
            updatedAt: now,
          );
    batch.set(ref, enrollment.toMap(), SetOptions(merge: true));
    await batch.commit();
    return enrollment;
  }

  Future<WorkoutProgram> saveCustomProgram(
    String uid,
    WorkoutProgram program,
  ) async {
    final ref = program.id.isEmpty
        ? _customPrograms(uid).doc()
        : _customPrograms(uid).doc(program.id);
    final saved = WorkoutProgram(
      id: ref.id,
      title: program.title,
      description: program.description,
      goal: program.goal,
      level: program.level,
      durationWeeks: program.durationWeeks,
      daysPerWeek: program.daysPerWeek,
      estimatedMinutesPerDay: program.estimatedMinutesPerDay,
      equipment: program.equipment,
      workoutDays: program.workoutDays,
    );
    await ref.set({
      ...saved.toMap(),
      'uid': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return saved;
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
    await _firestore.runTransaction((transaction) async {
      final existingDoc = await transaction.get(ref);
      final existing = existingDoc.exists
          ? WorkoutSession.fromMap(ref.id, existingDoc.data()!)
          : null;
      final wasCompleted = existing?.status == 'completed';
      final isCompleted = saved.status == 'completed';
      final caloriesDelta = (isCompleted ? saved.caloriesBurned : 0) -
          (wasCompleted ? existing!.caloriesBurned : 0);
      final minutesDelta = (isCompleted ? saved.totalDurationMinutes : 0) -
          (wasCompleted ? existing!.totalDurationMinutes : 0);
      final completedDelta = (isCompleted ? 1 : 0) - (wasCompleted ? 1 : 0);

      transaction.set(ref, saved.toMap(), SetOptions(merge: true));
      transaction.set(dailyRef, saved.toMap(), SetOptions(merge: true));
      if (caloriesDelta != 0 || minutesDelta != 0 || completedDelta != 0) {
        transaction.set(
          _firestore
              .collection('calorie_logs')
              .doc(saved.uid)
              .collection('daily')
              .doc(saved.dateKey),
          {
            'uid': saved.uid,
            'date': saved.dateKey,
            'caloriesBurned': FieldValue.increment(caloriesDelta),
            'netCalories': FieldValue.increment(-caloriesDelta),
            'workoutMinutes': FieldValue.increment(minutesDelta),
            'workoutsCompleted': FieldValue.increment(completedDelta),
            'updatedAt': Timestamp.now(),
          },
          SetOptions(merge: true),
        );
      }
    });
    return saved;
  }

  Future<UserWorkoutProgram> skipCurrentProgramDay(
    String uid,
    WorkoutProgram program,
    UserWorkoutProgram enrollment,
  ) async {
    final now = DateTime.now();
    final next =
        _advanceProgram(program, enrollment, completedSessionId: null).copyWith(
      skippedDays: [...enrollment.skippedDays, enrollment.currentDay],
      updatedAt: now,
    );
    await _programs(uid).doc(enrollment.programId).set(
          next.toMap(),
          SetOptions(merge: true),
        );
    return next;
  }

  Future<UserWorkoutProgram> completeProgramSession({
    required String uid,
    required WorkoutProgram program,
    required UserWorkoutProgram enrollment,
    required String sessionId,
  }) async {
    final next = _advanceProgram(
      program,
      enrollment,
      completedSessionId: sessionId,
    );
    await _programs(uid).doc(enrollment.programId).set(
          next.toMap(),
          SetOptions(merge: true),
        );
    return next;
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

  CollectionReference<Map<String, dynamic>> _programs(String uid) {
    return _firestore
        .collection('user_workout_programs')
        .doc(uid)
        .collection('programs');
  }

  CollectionReference<Map<String, dynamic>> _customPrograms(String uid) {
    return _firestore
        .collection('custom_workout_programs')
        .doc(uid)
        .collection('programs');
  }

  int _firstProgramDay(WorkoutProgram program) {
    if (program.workoutDays.isEmpty) return 1;
    final days = [...program.workoutDays]
      ..sort((a, b) => a.day.compareTo(b.day));
    return days.first.day;
  }

  UserWorkoutProgram _advanceProgram(
    WorkoutProgram program,
    UserWorkoutProgram enrollment, {
    required String? completedSessionId,
  }) {
    final days = [...program.workoutDays]
      ..sort((a, b) => a.day.compareTo(b.day));
    if (days.isEmpty) {
      return enrollment.copyWith(
        status: 'completed',
        completedSessionIds: [
          ...enrollment.completedSessionIds,
          if (completedSessionId != null) completedSessionId,
        ],
        updatedAt: DateTime.now(),
      );
    }
    final index = days.indexWhere((day) => day.day == enrollment.currentDay);
    final nextIndex = index == -1 ? 0 : index + 1;
    var nextWeek = enrollment.currentWeek;
    var nextDay = days.first.day;
    var status = enrollment.status;
    if (nextIndex < days.length) {
      nextDay = days[nextIndex].day;
    } else {
      nextWeek++;
      nextDay = days.first.day;
      if (nextWeek > program.durationWeeks) {
        status = 'completed';
        nextWeek = program.durationWeeks;
        nextDay = days.last.day;
      }
    }
    return enrollment.copyWith(
      currentWeek: nextWeek,
      currentDay: nextDay,
      status: status,
      completedSessionIds: [
        ...enrollment.completedSessionIds,
        if (completedSessionId != null) completedSessionId,
      ],
      updatedAt: DateTime.now(),
    );
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
