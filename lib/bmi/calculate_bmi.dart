import 'dart:math';

class BmiLogic {
  final int height;
  final int weight;
  BmiLogic({required this.height, required this.weight, required this.bmi});

  double bmi;

  String calculateBMI() {
    bmi = weight / pow(height / 100, 2);
    return bmi.toStringAsFixed(1);
  }

  String getResult() {
    if (bmi >= 25) {
      return 'Overweight';
    } else if (bmi > 18.5) {
      return 'Normal';
    } else {
      return 'Underweight';
    }
  }

  String getInterpretation() {
    if (bmi >= 25) {
      return 'You have a higher than normal body weight. Try to exercise more.\n 💪🚵🚴🏊🏇🏃';
    } else if (bmi >= 18.5) {
      return 'You have a normal body weight. Good job!\n 🍇🍉🍍🍒🌽';
    } else {
      return 'You have a lower than normal body weight. You can eat a bit more.\n 🍲🍱🍳🍗🍒🍎';
    }
  }
}

class BMR {
  final int height;
  final int weight;
  final String gender;
  final int age;
  BMR(
      {required this.height,
      required this.weight,
      required this.gender,
      required this.age,
      required this.bmr});

  double bmr;
  String calculateBMR() {
    if (gender == 'Male') {
      bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
      return bmr.toStringAsFixed(1);
    } else if (gender == 'Female') {
      bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
      return bmr.toStringAsFixed(1);
    }
    return 'BMR';
  }
}

// Men	BMR = 88.362 + (13.397 × weight in kg) + (4.799 × height in cm) - (5.677 × age in years)
// Women	BMR = 447.593 + (9.247 × weight in kg) + (3.098 × height in cm) - (4.330 × age in years)