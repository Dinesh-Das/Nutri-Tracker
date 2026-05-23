import 'package:cloud_firestore/cloud_firestore.dart';

class MealEntry {
  MealEntry({
    required this.mealType,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.quantity,
    required this.unit,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  final String mealType;
  final String foodName;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double quantity;
  final String unit;
  final DateTime timestamp;

  factory MealEntry.fromMap(Map<String, dynamic> map) {
    final timestamp = map['timestamp'];
    return MealEntry(
      mealType: map['mealType'] ?? 'snack',
      foodName: map['foodName'] ?? '',
      calories: (map['calories'] as num?)?.toInt() ?? 0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0,
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] ?? 'grams',
      timestamp: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mealType': mealType,
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'quantity': quantity,
      'unit': unit,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

class DailyCalorieLog {
  DailyCalorieLog({
    required this.date,
    this.totalCalories = 0,
    this.totalProtein = 0,
    this.totalCarbs = 0,
    this.totalFat = 0,
    this.waterIntakeMl = 0,
    this.meals = const [],
  });

  final String date;
  final int totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final int waterIntakeMl;
  final List<MealEntry> meals;

  factory DailyCalorieLog.empty(String date) => DailyCalorieLog(date: date);

  factory DailyCalorieLog.fromMap(String date, Map<String, dynamic>? map) {
    if (map == null) return DailyCalorieLog.empty(date);
    return DailyCalorieLog(
      date: map['date'] ?? date,
      totalCalories: (map['totalCalories'] as num?)?.toInt() ?? 0,
      totalProtein: (map['totalProtein'] as num?)?.toDouble() ?? 0,
      totalCarbs: (map['totalCarbs'] as num?)?.toDouble() ?? 0,
      totalFat: (map['totalFat'] as num?)?.toDouble() ?? 0,
      waterIntakeMl: (map['waterIntakeMl'] as num?)?.toInt() ?? 0,
      meals: ((map['meals'] as List?) ?? const [])
          .whereType<Map>()
          .map((item) => MealEntry.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}
