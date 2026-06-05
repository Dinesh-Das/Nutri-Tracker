import 'package:cloud_firestore/cloud_firestore.dart';

enum AchievementType {
  logStreak7,
  logStreak30,
  logStreak100,
  firstWorkout,
  workouts10,
  workouts50,
  goalReached,
  bmiNormal,
  recipeTried10,
  waterGoalWeek,
}

class Achievement {
  Achievement({
    required this.type,
    required this.unlockedAt,
  });

  final AchievementType type;
  final DateTime unlockedAt;

  String get id => type.name;

  String get title {
    switch (type) {
      case AchievementType.logStreak7:
        return '7-day logging streak';
      case AchievementType.logStreak30:
        return '30-day logging streak';
      case AchievementType.logStreak100:
        return '100-day logging streak';
      case AchievementType.firstWorkout:
        return 'First workout';
      case AchievementType.workouts10:
        return '10 workouts';
      case AchievementType.workouts50:
        return '50 workouts';
      case AchievementType.goalReached:
        return 'Goal reached';
      case AchievementType.bmiNormal:
        return 'Healthy BMI';
      case AchievementType.recipeTried10:
        return '10 recipes tried';
      case AchievementType.waterGoalWeek:
        return 'Water goal week';
    }
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    final rawType = map['type']?.toString() ?? '';
    final timestamp = map['unlockedAt'];
    return Achievement(
      type: AchievementType.values.firstWhere(
        (type) => type.name == rawType,
        orElse: () => AchievementType.goalReached,
      ),
      unlockedAt: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type.name,
        'unlockedAt': Timestamp.fromDate(unlockedAt),
      };
}
