import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutri_tracker/models/workout_program.dart';

class UserWorkoutProgram {
  UserWorkoutProgram({
    required this.id,
    required this.uid,
    required this.programId,
    required this.title,
    DateTime? startedAt,
    this.currentWeek = 1,
    this.currentDay = 1,
    this.status = 'active',
    this.completedSessionIds = const [],
    this.skippedDays = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : startedAt = startedAt ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String uid;
  final String programId;
  final String title;
  final DateTime startedAt;
  final int currentWeek;
  final int currentDay;
  final String status;
  final List<String> completedSessionIds;
  final List<int> skippedDays;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory UserWorkoutProgram.fromMap(String id, Map<String, dynamic> map) {
    return UserWorkoutProgram(
      id: id,
      uid: map['uid']?.toString() ?? '',
      programId: map['programId']?.toString() ?? id,
      title: map['title']?.toString() ?? 'Workout program',
      startedAt: _toDate(map['startedAt']),
      currentWeek: (map['currentWeek'] as num?)?.toInt() ?? 1,
      currentDay: (map['currentDay'] as num?)?.toInt() ?? 1,
      status: map['status']?.toString() ?? 'active',
      completedSessionIds:
          List<String>.from(map['completedSessionIds'] ?? const []),
      skippedDays: ((map['skippedDays'] as List?) ?? const [])
          .whereType<num>()
          .map((day) => day.toInt())
          .toList(),
      createdAt: _toDate(map['createdAt']),
      updatedAt: _toDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'programId': programId,
      'title': title,
      'startedAt': Timestamp.fromDate(startedAt),
      'currentWeek': currentWeek,
      'currentDay': currentDay,
      'status': status,
      'completedSessionIds': completedSessionIds,
      'skippedDays': skippedDays,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserWorkoutProgram copyWith({
    String? id,
    String? uid,
    String? programId,
    String? title,
    DateTime? startedAt,
    int? currentWeek,
    int? currentDay,
    String? status,
    List<String>? completedSessionIds,
    List<int>? skippedDays,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserWorkoutProgram(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      programId: programId ?? this.programId,
      title: title ?? this.title,
      startedAt: startedAt ?? this.startedAt,
      currentWeek: currentWeek ?? this.currentWeek,
      currentDay: currentDay ?? this.currentDay,
      status: status ?? this.status,
      completedSessionIds: completedSessionIds ?? this.completedSessionIds,
      skippedDays: skippedDays ?? this.skippedDays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

class WorkoutProgramSessionSeed {
  const WorkoutProgramSessionSeed({
    required this.program,
    required this.enrollment,
  });

  final WorkoutProgram program;
  final UserWorkoutProgram enrollment;
}
