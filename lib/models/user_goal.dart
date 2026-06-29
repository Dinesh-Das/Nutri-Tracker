import 'package:cloud_firestore/cloud_firestore.dart';

class UserGoal {
  UserGoal({
    required this.id,
    required this.uid,
    required this.goalType,
    this.targetWeightKg,
    this.targetDate,
    required this.dailyCalorieGoal,
    required this.proteinGoalG,
    required this.carbsGoalG,
    required this.fatGoalG,
    required this.waterGoalMl,
    required this.stepGoal,
    required this.workoutsPerWeek,
    this.preferredWorkoutDays = const [],
    required this.workoutDurationMinutes,
    required this.fitnessLevel,
    required this.equipment,
    this.injuriesOrLimitations = '',
    this.dietPreference = '',
    this.allergies = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isActive = true,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String uid;
  final String goalType;
  final double? targetWeightKg;
  final DateTime? targetDate;
  final int dailyCalorieGoal;
  final int proteinGoalG;
  final int carbsGoalG;
  final int fatGoalG;
  final int waterGoalMl;
  final int stepGoal;
  final int workoutsPerWeek;
  final List<String> preferredWorkoutDays;
  final int workoutDurationMinutes;
  final String fitnessLevel;
  final String equipment;
  final String injuriesOrLimitations;
  final String dietPreference;
  final List<String> allergies;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  factory UserGoal.defaults(String uid) {
    return UserGoal(
      id: '',
      uid: uid,
      goalType: 'maintain',
      dailyCalorieGoal: 2000,
      proteinGoalG: 100,
      carbsGoalG: 250,
      fatGoalG: 65,
      waterGoalMl: 2500,
      stepGoal: 8000,
      workoutsPerWeek: 4,
      preferredWorkoutDays: const ['Mon', 'Tue', 'Thu', 'Sat'],
      workoutDurationMinutes: 30,
      fitnessLevel: 'beginner',
      equipment: 'none',
    );
  }

  factory UserGoal.fromMap(String id, Map<String, dynamic>? map) {
    if (map == null) return UserGoal.defaults('').copyWith(id: id);
    return UserGoal(
      id: id,
      uid: map['uid']?.toString() ?? '',
      goalType: map['goalType']?.toString() ?? 'maintain',
      targetWeightKg: (map['targetWeightKg'] as num?)?.toDouble(),
      targetDate: _toDate(map['targetDate']),
      dailyCalorieGoal: (map['dailyCalorieGoal'] as num?)?.toInt() ?? 2000,
      proteinGoalG: (map['proteinGoalG'] as num?)?.toInt() ?? 100,
      carbsGoalG: (map['carbsGoalG'] as num?)?.toInt() ?? 250,
      fatGoalG: (map['fatGoalG'] as num?)?.toInt() ?? 65,
      waterGoalMl: (map['waterGoalMl'] as num?)?.toInt() ?? 2500,
      stepGoal: (map['stepGoal'] as num?)?.toInt() ?? 8000,
      workoutsPerWeek: (map['workoutsPerWeek'] as num?)?.toInt() ?? 4,
      preferredWorkoutDays:
          List<String>.from(map['preferredWorkoutDays'] ?? const []),
      workoutDurationMinutes:
          (map['workoutDurationMinutes'] as num?)?.toInt() ?? 30,
      fitnessLevel: map['fitnessLevel']?.toString() ?? 'beginner',
      equipment: map['equipment']?.toString() ?? 'none',
      injuriesOrLimitations: map['injuriesOrLimitations']?.toString() ?? '',
      dietPreference: map['dietPreference']?.toString() ??
          map['dietaryPreference']?.toString() ??
          '',
      allergies: List<String>.from(map['allergies'] ?? const []),
      createdAt: _toDate(map['createdAt']),
      updatedAt: _toDate(map['updatedAt']),
      isActive: map['isActive'] != false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'goalType': goalType,
      'targetWeightKg': targetWeightKg,
      'targetDate': targetDate == null ? null : Timestamp.fromDate(targetDate!),
      'dailyCalorieGoal': dailyCalorieGoal,
      'proteinGoalG': proteinGoalG,
      'carbsGoalG': carbsGoalG,
      'fatGoalG': fatGoalG,
      'waterGoalMl': waterGoalMl,
      'stepGoal': stepGoal,
      'workoutsPerWeek': workoutsPerWeek,
      'preferredWorkoutDays': preferredWorkoutDays,
      'workoutDurationMinutes': workoutDurationMinutes,
      'fitnessLevel': fitnessLevel,
      'equipment': equipment,
      'injuriesOrLimitations': injuriesOrLimitations,
      'dietPreference': dietPreference,
      'allergies': allergies,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    }..removeWhere((key, value) => value == null);
  }

  UserGoal copyWith({
    String? id,
    String? uid,
    String? goalType,
    double? targetWeightKg,
    DateTime? targetDate,
    int? dailyCalorieGoal,
    int? proteinGoalG,
    int? carbsGoalG,
    int? fatGoalG,
    int? waterGoalMl,
    int? stepGoal,
    int? workoutsPerWeek,
    List<String>? preferredWorkoutDays,
    int? workoutDurationMinutes,
    String? fitnessLevel,
    String? equipment,
    String? injuriesOrLimitations,
    String? dietPreference,
    List<String>? allergies,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return UserGoal(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      goalType: goalType ?? this.goalType,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      targetDate: targetDate ?? this.targetDate,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      proteinGoalG: proteinGoalG ?? this.proteinGoalG,
      carbsGoalG: carbsGoalG ?? this.carbsGoalG,
      fatGoalG: fatGoalG ?? this.fatGoalG,
      waterGoalMl: waterGoalMl ?? this.waterGoalMl,
      stepGoal: stepGoal ?? this.stepGoal,
      workoutsPerWeek: workoutsPerWeek ?? this.workoutsPerWeek,
      preferredWorkoutDays: preferredWorkoutDays ?? this.preferredWorkoutDays,
      workoutDurationMinutes:
          workoutDurationMinutes ?? this.workoutDurationMinutes,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      equipment: equipment ?? this.equipment,
      injuriesOrLimitations:
          injuriesOrLimitations ?? this.injuriesOrLimitations,
      dietPreference: dietPreference ?? this.dietPreference,
      allergies: allergies ?? this.allergies,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  static DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
