import 'package:flutter/material.dart';

class ReminderPreference {
  const ReminderPreference({
    this.enabled = false,
    this.hour = 8,
    this.minute = 0,
    this.days = const [],
  });

  final bool enabled;
  final int hour;
  final int minute;
  final List<int> days;

  TimeOfDay get time => TimeOfDay(hour: hour, minute: minute);

  factory ReminderPreference.fromMap(
    Map<String, dynamic>? map, {
    required int defaultHour,
    int defaultMinute = 0,
  }) {
    if (map == null) {
      return ReminderPreference(hour: defaultHour, minute: defaultMinute);
    }
    return ReminderPreference(
      enabled: map['enabled'] == true,
      hour: (map['hour'] as num?)?.toInt() ?? defaultHour,
      minute: (map['minute'] as num?)?.toInt() ?? defaultMinute,
      days: ((map['days'] as List?) ?? const [])
          .whereType<num>()
          .map((day) => day.toInt())
          .where((day) => day >= 1 && day <= 7)
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'hour': hour,
      'minute': minute,
      'days': days,
    };
  }

  ReminderPreference copyWith({
    bool? enabled,
    int? hour,
    int? minute,
    List<int>? days,
  }) {
    return ReminderPreference(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      days: days ?? this.days,
    );
  }
}

class UserNotificationSettings {
  const UserNotificationSettings({
    this.meal = const ReminderPreference(hour: 8),
    this.water = const ReminderPreference(hour: 10),
    this.workout = const ReminderPreference(
      hour: 18,
      days: [1, 3, 5],
    ),
    this.weighIn = const ReminderPreference(hour: 7),
    this.streak = const ReminderPreference(hour: 21),
  });

  final ReminderPreference meal;
  final ReminderPreference water;
  final ReminderPreference workout;
  final ReminderPreference weighIn;
  final ReminderPreference streak;

  factory UserNotificationSettings.fromMap(Map<String, dynamic>? map) {
    return UserNotificationSettings(
      meal: ReminderPreference.fromMap(
        map?['meal'] is Map ? Map<String, dynamic>.from(map!['meal']) : null,
        defaultHour: 8,
      ),
      water: ReminderPreference.fromMap(
        map?['water'] is Map ? Map<String, dynamic>.from(map!['water']) : null,
        defaultHour: 10,
      ),
      workout: ReminderPreference.fromMap(
        map?['workout'] is Map
            ? Map<String, dynamic>.from(map!['workout'])
            : null,
        defaultHour: 18,
      ),
      weighIn: ReminderPreference.fromMap(
        map?['weighIn'] is Map
            ? Map<String, dynamic>.from(map!['weighIn'])
            : null,
        defaultHour: 7,
      ),
      streak: ReminderPreference.fromMap(
        map?['streak'] is Map
            ? Map<String, dynamic>.from(map!['streak'])
            : null,
        defaultHour: 21,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'meal': meal.toMap(),
      'water': water.toMap(),
      'workout': workout.toMap(),
      'weighIn': weighIn.toMap(),
      'streak': streak.toMap(),
    };
  }

  UserNotificationSettings copyWith({
    ReminderPreference? meal,
    ReminderPreference? water,
    ReminderPreference? workout,
    ReminderPreference? weighIn,
    ReminderPreference? streak,
  }) {
    return UserNotificationSettings(
      meal: meal ?? this.meal,
      water: water ?? this.water,
      workout: workout ?? this.workout,
      weighIn: weighIn ?? this.weighIn,
      streak: streak ?? this.streak,
    );
  }
}
