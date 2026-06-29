import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutExerciseLog {
  WorkoutExerciseLog({
    required this.exerciseId,
    required this.name,
    this.sets,
    this.reps,
    this.durationSeconds,
    this.restSeconds = 45,
    this.completed = false,
    this.caloriesBurned = 0,
    this.notes = '',
  });

  final String exerciseId;
  final String name;
  final int? sets;
  final int? reps;
  final int? durationSeconds;
  final int restSeconds;
  final bool completed;
  final int caloriesBurned;
  final String notes;

  factory WorkoutExerciseLog.fromMap(Map<String, dynamic> map) {
    return WorkoutExerciseLog(
      exerciseId: map['exerciseId']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      sets: (map['sets'] as num?)?.toInt(),
      reps: (map['reps'] as num?)?.toInt(),
      durationSeconds: (map['durationSeconds'] as num?)?.toInt(),
      restSeconds: (map['restSeconds'] as num?)?.toInt() ?? 45,
      completed: map['completed'] == true,
      caloriesBurned: (map['caloriesBurned'] as num?)?.toInt() ?? 0,
      notes: map['notes']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'name': name,
      'sets': sets,
      'reps': reps,
      'durationSeconds': durationSeconds,
      'restSeconds': restSeconds,
      'completed': completed,
      'caloriesBurned': caloriesBurned,
      'notes': notes,
    }..removeWhere((key, value) => value == null);
  }

  WorkoutExerciseLog copyWith({
    int? sets,
    int? reps,
    int? durationSeconds,
    int? restSeconds,
    bool? completed,
    int? caloriesBurned,
    String? notes,
  }) {
    return WorkoutExerciseLog(
      exerciseId: exerciseId,
      name: name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      completed: completed ?? this.completed,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      notes: notes ?? this.notes,
    );
  }
}

class WorkoutSession {
  WorkoutSession({
    required this.id,
    required this.uid,
    this.programId,
    required this.title,
    required this.date,
    required this.dateKey,
    this.startedAt,
    this.completedAt,
    this.status = 'planned',
    this.totalDurationMinutes = 0,
    this.caloriesBurned = 0,
    this.exercises = const [],
    this.notes = '',
    this.source = 'manual',
  });

  final String id;
  final String uid;
  final String? programId;
  final String title;
  final DateTime date;
  final String dateKey;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String status;
  final int totalDurationMinutes;
  final int caloriesBurned;
  final List<WorkoutExerciseLog> exercises;
  final String notes;
  final String source;

  factory WorkoutSession.fromMap(String id, Map<String, dynamic> map) {
    final date = _toDate(map['date']) ?? DateTime.now();
    return WorkoutSession(
      id: id,
      uid: map['uid']?.toString() ?? '',
      programId: map['programId']?.toString(),
      title: map['title']?.toString() ?? 'Workout',
      date: date,
      dateKey: map['dateKey']?.toString() ?? _dateKey(date),
      startedAt: _toDate(map['startedAt']),
      completedAt: _toDate(map['completedAt']),
      status: map['status']?.toString() ?? 'planned',
      totalDurationMinutes: (map['totalDurationMinutes'] as num?)?.toInt() ?? 0,
      caloriesBurned: (map['caloriesBurned'] as num?)?.toInt() ?? 0,
      exercises: ((map['exercises'] as List?) ?? const [])
          .whereType<Map>()
          .map((item) =>
              WorkoutExerciseLog.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      notes: map['notes']?.toString() ?? '',
      source: map['source']?.toString() ?? 'manual',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'programId': programId,
      'title': title,
      'date': Timestamp.fromDate(date),
      'dateKey': dateKey,
      'startedAt': startedAt == null ? null : Timestamp.fromDate(startedAt!),
      'completedAt':
          completedAt == null ? null : Timestamp.fromDate(completedAt!),
      'status': status,
      'totalDurationMinutes': totalDurationMinutes,
      'caloriesBurned': caloriesBurned,
      'exercises': exercises.map((exercise) => exercise.toMap()).toList(),
      'notes': notes,
      'source': source,
    }..removeWhere((key, value) => value == null);
  }

  WorkoutSession copyWith({
    String? id,
    String? uid,
    String? programId,
    String? title,
    DateTime? date,
    String? dateKey,
    DateTime? startedAt,
    DateTime? completedAt,
    String? status,
    int? totalDurationMinutes,
    int? caloriesBurned,
    List<WorkoutExerciseLog>? exercises,
    String? notes,
    String? source,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      programId: programId ?? this.programId,
      title: title ?? this.title,
      date: date ?? this.date,
      dateKey: dateKey ?? this.dateKey,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      totalDurationMinutes: totalDurationMinutes ?? this.totalDurationMinutes,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      exercises: exercises ?? this.exercises,
      notes: notes ?? this.notes,
      source: source ?? this.source,
    );
  }

  static DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
