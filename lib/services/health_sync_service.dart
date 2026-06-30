import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutri_tracker/repositories/nutrition_repository.dart';
import 'package:nutri_tracker/services/daily_summary_service.dart';
import 'package:nutri_tracker/services/health_service.dart';

class HealthSyncSnapshot {
  const HealthSyncSnapshot({
    this.steps = 0,
    this.activeCalories = 0,
    this.weightKg,
    this.bmi,
    this.permissionDenied = false,
    this.message = 'Health data synced.',
  });

  final int steps;
  final double activeCalories;
  final double? weightKg;
  final double? bmi;
  final bool permissionDenied;
  final String message;
}

class HealthSyncService {
  HealthSyncService({
    HealthService? healthService,
    FirebaseFirestore? firestore,
  })  : _healthService = healthService ?? HealthService(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  final HealthService _healthService;
  final FirebaseFirestore _firestore;

  Future<HealthSyncSnapshot> syncToday(String uid) async {
    try {
      final steps = await _healthService.getTodaySteps();
      final activeCalories = await _healthService.getTodayActiveCalories();
      await saveToday(
        uid: uid,
        steps: steps,
        activeCalories: activeCalories.round(),
      );
      return HealthSyncSnapshot(
        steps: steps,
        activeCalories: activeCalories,
      );
    } catch (error) {
      return const HealthSyncSnapshot(
        permissionDenied: true,
        message:
            'Health permissions are unavailable. You can keep using manual tracking.',
      );
    }
  }

  Future<HealthSyncSnapshot> saveToday({
    required String uid,
    required int steps,
    required int activeCalories,
  }) async {
    final today = DateTime.now();
    final key = NutritionRepository(firestore: _firestore).dateKey(today);
    final ref = _firestore
        .collection('calorie_logs')
        .doc(uid)
        .collection('daily')
        .doc(key);
    final normalizedSteps = max(0, steps);
    final normalizedActiveCalories = max(0, activeCalories);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final oldHealthActiveCalories =
          (snapshot.data()?['healthActiveCalories'] as num?)?.toInt() ?? 0;
      final delta = normalizedActiveCalories - oldHealthActiveCalories;
      transaction.set(
        ref,
        {
          'uid': uid,
          'date': key,
          'steps': normalizedSteps,
          'healthActiveCalories': normalizedActiveCalories,
          'caloriesBurned': FieldValue.increment(delta),
          'netCalories': FieldValue.increment(-delta),
          'updatedAt': Timestamp.now(),
        },
        SetOptions(merge: true),
      );
    });
    await DailySummaryService(firestore: _firestore).rebuildSummary(uid, today);
    return HealthSyncSnapshot(
      steps: normalizedSteps,
      activeCalories: normalizedActiveCalories.toDouble(),
      message: 'Health data saved.',
    );
  }
}
