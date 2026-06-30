class WorkoutExercise {
  const WorkoutExercise({
    required this.name,
    required this.muscleGroup,
    required this.sets,
    required this.reps,
    required this.durationSeconds,
    required this.restSeconds,
    required this.instructions,
    required this.emoji,
  });

  final String name;
  final String muscleGroup;
  final int sets;
  final int reps;
  final int durationSeconds;
  final int restSeconds;
  final String instructions;
  final String emoji;
}

class WorkoutPlan {
  const WorkoutPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.durationMinutes,
    required this.estimatedCalories,
    required this.exercises,
    required this.emoji,
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final String difficulty;
  final int durationMinutes;
  final int estimatedCalories;
  final List<WorkoutExercise> exercises;
  final String emoji;
}
