class WorkoutProgram {
  const WorkoutProgram({
    required this.id,
    required this.title,
    required this.description,
    required this.goal,
    required this.level,
    required this.durationWeeks,
    required this.daysPerWeek,
    required this.estimatedMinutesPerDay,
    required this.equipment,
    required this.workoutDays,
  });

  final String id;
  final String title;
  final String description;
  final String goal;
  final String level;
  final int durationWeeks;
  final int daysPerWeek;
  final int estimatedMinutesPerDay;
  final String equipment;
  final List<WorkoutProgramDay> workoutDays;

  factory WorkoutProgram.fromMap(Map<String, dynamic> map) {
    return WorkoutProgram(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      goal: map['goal']?.toString() ?? 'fitness',
      level: map['level']?.toString() ?? 'beginner',
      durationWeeks: (map['durationWeeks'] as num?)?.toInt() ?? 1,
      daysPerWeek: (map['daysPerWeek'] as num?)?.toInt() ?? 3,
      estimatedMinutesPerDay:
          (map['estimatedMinutesPerDay'] as num?)?.toInt() ?? 20,
      equipment: map['equipment']?.toString() ?? 'none',
      workoutDays: ((map['workoutDays'] as List?) ?? const [])
          .whereType<Map>()
          .map((item) =>
              WorkoutProgramDay.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'goal': goal,
      'level': level,
      'durationWeeks': durationWeeks,
      'daysPerWeek': daysPerWeek,
      'estimatedMinutesPerDay': estimatedMinutesPerDay,
      'equipment': equipment,
      'workoutDays': workoutDays.map((day) => day.toMap()).toList(),
    };
  }
}

class WorkoutProgramDay {
  const WorkoutProgramDay({
    required this.day,
    required this.title,
    required this.exerciseIds,
  });

  final int day;
  final String title;
  final List<String> exerciseIds;

  factory WorkoutProgramDay.fromMap(Map<String, dynamic> map) {
    return WorkoutProgramDay(
      day: (map['day'] as num?)?.toInt() ?? 1,
      title: map['title']?.toString() ?? 'Workout',
      exerciseIds: List<String>.from(map['exerciseIds'] ?? const []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'title': title,
      'exerciseIds': exerciseIds,
    };
  }
}
