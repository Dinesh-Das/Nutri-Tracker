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
