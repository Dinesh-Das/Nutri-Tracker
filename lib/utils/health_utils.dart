import 'package:flutter/material.dart';

String getBmiCategory(double bmi) {
  if (bmi <= 0) return 'Not calculated';
  if (bmi < 18.5) return 'Underweight';
  if (bmi < 25.0) return 'Normal';
  if (bmi < 30.0) return 'Overweight';
  return 'Obese';
}

Color getBmiColor(double bmi) {
  if (bmi <= 0) return Colors.grey;
  if (bmi < 18.5) return Colors.blue;
  if (bmi < 25.0) return Colors.green;
  if (bmi < 30.0) return Colors.orange;
  return Colors.red;
}

double activityMultiplier(String? level) {
  switch (level) {
    case 'lightly_active':
      return 1.375;
    case 'moderately_active':
      return 1.55;
    case 'very_active':
      return 1.725;
    case 'extra_active':
      return 1.9;
    case 'sedentary':
    default:
      return 1.2;
  }
}

double calculateBmi(double weightKg, double heightCm) {
  if (heightCm <= 0) return 0;
  final heightM = heightCm / 100;
  return weightKg / (heightM * heightM);
}

double calculateBmr({
  required String gender,
  required double weightKg,
  required double heightCm,
  required int age,
}) {
  if (gender.toLowerCase().startsWith('male')) {
    return 88.362 + (13.397 * weightKg) + (4.799 * heightCm) - (5.677 * age);
  }
  return 447.593 + (9.247 * weightKg) + (3.098 * heightCm) - (4.330 * age);
}

int calculateCalorieGoal({
  required String gender,
  required double weightKg,
  required double heightCm,
  required int age,
  required String activityLevel,
  required String goalType,
}) {
  final bmr = calculateBmr(
    gender: gender,
    weightKg: weightKg,
    heightCm: heightCm,
    age: age,
  );
  final goal = goalType.toLowerCase();
  final adjustment = switch (goal) {
    'lose' || 'lose_weight' => -350,
    'gain' || 'gain_muscle' => 300,
    'improve_fitness' => 100,
    _ => 0,
  };
  return (bmr * activityMultiplier(activityLevel) + adjustment)
      .clamp(1200, 4500)
      .round();
}

MacroTargets calculateMacroTargets({
  required int calorieGoal,
  required String goalType,
  double? weightKg,
}) {
  final goal = goalType.toLowerCase();
  final proteinCaloriesRatio =
      goal == 'gain_muscle' || goal == 'improve_fitness' ? 0.28 : 0.24;
  final fatCaloriesRatio = goal == 'lose_weight' || goal == 'lose' ? 0.26 : 0.3;
  final carbsCaloriesRatio = 1 - proteinCaloriesRatio - fatCaloriesRatio;
  final protein = calorieGoal * proteinCaloriesRatio / 4;
  final minimumProtein = weightKg == null ? 0 : weightKg * 1.2;
  return MacroTargets(
    proteinGoalG:
        protein < minimumProtein ? minimumProtein.round() : protein.round(),
    carbsGoalG: (calorieGoal * carbsCaloriesRatio / 4).round(),
    fatGoalG: (calorieGoal * fatCaloriesRatio / 9).round(),
  );
}

const Map<String, double> metValues = {
  'running': 9.8,
  'walking': 3.5,
  'cycling': 7.5,
  'swimming': 8.0,
  'yoga': 2.5,
  'strength_training': 5.0,
  'hiit': 10.0,
  'cricket': 5.5,
  'football': 7.0,
  'badminton': 5.5,
  'kabaddi': 8.0,
  'dance': 6.0,
  'pilates': 3.0,
  'rowing': 7.0,
  'elliptical': 5.0,
  'stair_climbing': 8.8,
  'tennis': 7.3,
  'basketball': 6.5,
  'volleyball': 4.0,
  'skipping': 11.0,
  'hiking': 6.0,
  'surya_namaskar': 3.8,
};

int estimateCaloriesBurned({
  required String exercise,
  required int durationMinutes,
  required double weightKg,
}) {
  final normalized = exercise.toLowerCase().trim().replaceAll(' ', '_');
  final met = metValues[normalized] ?? 5.0;
  return estimateExerciseCalories(
    metValue: met,
    durationMinutes: durationMinutes,
    weightKg: weightKg,
  );
}

int estimateExerciseCalories({
  required double metValue,
  required int durationMinutes,
  required double weightKg,
}) {
  if (durationMinutes <= 0 || weightKg <= 0) return 0;
  return ((metValue * 3.5 * weightKg / 200) * durationMinutes).round();
}

class MacroTargets {
  const MacroTargets({
    required this.proteinGoalG,
    required this.carbsGoalG,
    required this.fatGoalG,
  });

  final int proteinGoalG;
  final int carbsGoalG;
  final int fatGoalG;
}
