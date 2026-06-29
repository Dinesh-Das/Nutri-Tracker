import 'package:cloud_firestore/cloud_firestore.dart';

class DailyHealthSummary {
  const DailyHealthSummary({
    required this.uid,
    required this.dateKey,
    this.caloriesConsumed = 0,
    this.caloriesBurned = 0,
    this.netCalories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.fiber = 0,
    this.waterIntakeMl = 0,
    this.steps = 0,
    this.workoutMinutes = 0,
    this.workoutsCompleted = 0,
    this.weightKg,
    this.bmi,
    this.updatedAt,
  });

  final String uid;
  final String dateKey;
  final int caloriesConsumed;
  final int caloriesBurned;
  final int netCalories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final int waterIntakeMl;
  final int steps;
  final int workoutMinutes;
  final int workoutsCompleted;
  final double? weightKg;
  final double? bmi;
  final DateTime? updatedAt;

  factory DailyHealthSummary.fromMap(
      String dateKey, Map<String, dynamic>? map) {
    if (map == null) {
      return DailyHealthSummary(uid: '', dateKey: dateKey);
    }
    final consumed = (map['caloriesConsumed'] as num?)?.toInt() ??
        (map['totalCalories'] as num?)?.toInt() ??
        0;
    final burned = (map['caloriesBurned'] as num?)?.toInt() ?? 0;
    return DailyHealthSummary(
      uid: map['uid']?.toString() ?? '',
      dateKey: map['dateKey']?.toString() ?? map['date']?.toString() ?? dateKey,
      caloriesConsumed: consumed,
      caloriesBurned: burned,
      netCalories: (map['netCalories'] as num?)?.toInt() ?? consumed - burned,
      protein: (map['protein'] as num?)?.toDouble() ??
          (map['totalProtein'] as num?)?.toDouble() ??
          0,
      carbs: (map['carbs'] as num?)?.toDouble() ??
          (map['totalCarbs'] as num?)?.toDouble() ??
          0,
      fat: (map['fat'] as num?)?.toDouble() ??
          (map['totalFat'] as num?)?.toDouble() ??
          0,
      fiber: (map['fiber'] as num?)?.toDouble() ??
          (map['totalFiber'] as num?)?.toDouble() ??
          0,
      waterIntakeMl: (map['waterIntakeMl'] as num?)?.toInt() ?? 0,
      steps: (map['steps'] as num?)?.toInt() ?? 0,
      workoutMinutes: (map['workoutMinutes'] as num?)?.toInt() ?? 0,
      workoutsCompleted: (map['workoutsCompleted'] as num?)?.toInt() ?? 0,
      weightKg: (map['weightKg'] as num?)?.toDouble(),
      bmi: (map['bmi'] as num?)?.toDouble(),
      updatedAt: _toDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'dateKey': dateKey,
      'caloriesConsumed': caloriesConsumed,
      'caloriesBurned': caloriesBurned,
      'netCalories': netCalories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'waterIntakeMl': waterIntakeMl,
      'steps': steps,
      'workoutMinutes': workoutMinutes,
      'workoutsCompleted': workoutsCompleted,
      'weightKg': weightKg,
      'bmi': bmi,
      'updatedAt': Timestamp.fromDate(updatedAt ?? DateTime.now()),
    }..removeWhere((key, value) => value == null);
  }

  static DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
