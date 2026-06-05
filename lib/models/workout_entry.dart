import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseEntry {
  ExerciseEntry({
    required this.id,
    required this.name,
    required this.category,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.timestamp,
    this.notes,
    this.sets,
    this.reps,
    this.weightKg,
  });

  final String id;
  final String name;
  final String category;
  final int durationMinutes;
  final int caloriesBurned;
  final DateTime timestamp;
  final String? notes;
  final int? sets;
  final int? reps;
  final double? weightKg;

  factory ExerciseEntry.fromMap(String id, Map<String, dynamic> map) {
    final timestamp = map['timestamp'];
    return ExerciseEntry(
      id: id,
      name: map['name']?.toString() ?? '',
      category: map['category']?.toString() ?? 'cardio',
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 0,
      caloriesBurned: (map['caloriesBurned'] as num?)?.toInt() ?? 0,
      timestamp: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
      notes: map['notes']?.toString(),
      sets: (map['sets'] as num?)?.toInt(),
      reps: (map['reps'] as num?)?.toInt(),
      weightKg: (map['weightKg'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'timestamp': Timestamp.fromDate(timestamp),
      'notes': notes,
      'sets': sets,
      'reps': reps,
      'weightKg': weightKg,
    }..removeWhere((key, value) => value == null);
  }
}

class ExerciseOption {
  const ExerciseOption({
    required this.name,
    required this.key,
    required this.category,
  });

  final String name;
  final String key;
  final String category;

  Map<String, dynamic> toMap() => {
        'name': name,
        'key': key,
        'category': category,
      };

  factory ExerciseOption.fromMap(Map<String, dynamic> map) {
    return ExerciseOption(
      name: map['name']?.toString() ?? '',
      key: map['key']?.toString() ?? '',
      category: map['category']?.toString() ?? 'cardio',
    );
  }
}
