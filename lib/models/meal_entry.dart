import 'package:cloud_firestore/cloud_firestore.dart';

class MealEntry {
  MealEntry({
    this.id = '',
    this.uid,
    this.dateKey,
    this.source = 'manual',
    required this.mealType,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.quantity,
    required this.unit,
    this.servingDescription,
    this.fiber = 0,
    this.sugar = 0,
    this.sodium = 0,
    DateTime? timestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : timestamp = timestamp ?? createdAt ?? DateTime.now(),
        createdAt = createdAt ?? timestamp ?? DateTime.now(),
        updatedAt = updatedAt ?? timestamp ?? createdAt ?? DateTime.now();

  final String id;
  final String? uid;
  final String? dateKey;
  final String source;
  final String mealType;
  final String foodName;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double quantity;
  final String unit;
  final String? servingDescription;
  final double fiber;
  final double sugar;
  final double sodium;
  final DateTime timestamp;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory MealEntry.fromMap(Map<String, dynamic> map) {
    final parsedTimestamp =
        _toDate(map['timestamp']) ?? _toDate(map['createdAt']);
    final quantity = (map['quantity'] as num?)?.toDouble() ?? 0;
    final unit = map['unit']?.toString() ?? 'grams';
    return MealEntry(
      id: map['id']?.toString() ?? '',
      uid: map['uid']?.toString(),
      dateKey: map['dateKey']?.toString() ?? map['date']?.toString(),
      source: map['source']?.toString() ?? 'manual',
      mealType: _normalizeMealType(map['mealType']?.toString()),
      foodName: map['foodName']?.toString() ?? map['name']?.toString() ?? '',
      calories: (map['calories'] as num?)?.toInt() ?? 0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0,
      quantity: quantity,
      unit: unit,
      servingDescription:
          map['servingDescription']?.toString() ?? '$quantity $unit',
      fiber: (map['fiber'] as num?)?.toDouble() ?? 0,
      sugar: (map['sugar'] as num?)?.toDouble() ?? 0,
      sodium: (map['sodium'] as num?)?.toDouble() ?? 0,
      timestamp: parsedTimestamp ?? DateTime.now(),
      createdAt: _toDate(map['createdAt']) ?? parsedTimestamp,
      updatedAt: _toDate(map['updatedAt']) ?? parsedTimestamp,
    );
  }

  Map<String, dynamic> toMap() {
    final data = {
      'id': id,
      'uid': uid,
      'dateKey': dateKey,
      'source': source,
      'mealType': mealType,
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'quantity': quantity,
      'unit': unit,
      'servingDescription': servingDescription,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'timestamp': Timestamp.fromDate(timestamp),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
    data.removeWhere((key, value) => value == null || value == '');
    return data;
  }

  MealEntry copyWith({
    String? id,
    String? uid,
    String? dateKey,
    String? source,
    String? mealType,
    String? foodName,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? quantity,
    String? unit,
    String? servingDescription,
    double? fiber,
    double? sugar,
    double? sodium,
    DateTime? timestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MealEntry(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      dateKey: dateKey ?? this.dateKey,
      source: source ?? this.source,
      mealType: mealType ?? this.mealType,
      foodName: foodName ?? this.foodName,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      servingDescription: servingDescription ?? this.servingDescription,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      sodium: sodium ?? this.sodium,
      timestamp: timestamp ?? this.timestamp,
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

  static String _normalizeMealType(String? value) {
    final normalized = (value ?? 'snack').toLowerCase().trim();
    return normalized == 'snacks' ? 'snack' : normalized;
  }
}

class DailyCalorieLog {
  DailyCalorieLog({
    required this.date,
    this.uid,
    this.totalCalories = 0,
    this.totalProtein = 0,
    this.totalCarbs = 0,
    this.totalFat = 0,
    this.totalFiber = 0,
    this.totalSugar = 0,
    this.totalSodium = 0,
    this.waterIntakeMl = 0,
    this.caloriesBurned = 0,
    this.steps = 0,
    this.healthActiveCalories = 0,
    this.netCalories = 0,
    this.meals = const [],
  });

  final String date;
  final String? uid;
  final int totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalFiber;
  final double totalSugar;
  final double totalSodium;
  final int waterIntakeMl;
  final int caloriesBurned;
  final int steps;
  final int healthActiveCalories;
  final int netCalories;
  final List<MealEntry> meals;

  factory DailyCalorieLog.empty(String date) => DailyCalorieLog(date: date);

  factory DailyCalorieLog.fromMap(String date, Map<String, dynamic>? map) {
    if (map == null) return DailyCalorieLog.empty(date);
    final calories = (map['totalCalories'] as num?)?.toInt() ??
        (map['caloriesConsumed'] as num?)?.toInt() ??
        0;
    final burned = (map['caloriesBurned'] as num?)?.toInt() ?? 0;
    return DailyCalorieLog(
      date: map['date'] ?? date,
      uid: map['uid']?.toString(),
      totalCalories: calories,
      totalProtein: (map['totalProtein'] as num?)?.toDouble() ??
          (map['protein'] as num?)?.toDouble() ??
          0,
      totalCarbs: (map['totalCarbs'] as num?)?.toDouble() ??
          (map['carbs'] as num?)?.toDouble() ??
          0,
      totalFat: (map['totalFat'] as num?)?.toDouble() ??
          (map['fat'] as num?)?.toDouble() ??
          0,
      totalFiber: (map['totalFiber'] as num?)?.toDouble() ??
          (map['fiber'] as num?)?.toDouble() ??
          0,
      totalSugar: (map['totalSugar'] as num?)?.toDouble() ??
          (map['sugar'] as num?)?.toDouble() ??
          0,
      totalSodium: (map['totalSodium'] as num?)?.toDouble() ??
          (map['sodium'] as num?)?.toDouble() ??
          0,
      waterIntakeMl: (map['waterIntakeMl'] as num?)?.toInt() ?? 0,
      caloriesBurned: burned,
      steps: (map['steps'] as num?)?.toInt() ?? 0,
      healthActiveCalories: (map['healthActiveCalories'] as num?)?.toInt() ?? 0,
      netCalories: (map['netCalories'] as num?)?.toInt() ?? calories - burned,
      meals: ((map['meals'] as List?) ?? const [])
          .whereType<Map>()
          .map((item) => MealEntry.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'uid': uid,
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'totalFiber': totalFiber,
      'totalSugar': totalSugar,
      'totalSodium': totalSodium,
      'waterIntakeMl': waterIntakeMl,
      'caloriesBurned': caloriesBurned,
      'steps': steps,
      'healthActiveCalories': healthActiveCalories,
      'netCalories': netCalories,
      'meals': meals.map((meal) => meal.toMap()).toList(),
    }..removeWhere((key, value) => value == null);
  }

  DailyCalorieLog copyWith({
    String? date,
    String? uid,
    int? totalCalories,
    double? totalProtein,
    double? totalCarbs,
    double? totalFat,
    double? totalFiber,
    double? totalSugar,
    double? totalSodium,
    int? waterIntakeMl,
    int? caloriesBurned,
    int? steps,
    int? healthActiveCalories,
    int? netCalories,
    List<MealEntry>? meals,
  }) {
    return DailyCalorieLog(
      date: date ?? this.date,
      uid: uid ?? this.uid,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      totalFiber: totalFiber ?? this.totalFiber,
      totalSugar: totalSugar ?? this.totalSugar,
      totalSodium: totalSodium ?? this.totalSodium,
      waterIntakeMl: waterIntakeMl ?? this.waterIntakeMl,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      steps: steps ?? this.steps,
      healthActiveCalories: healthActiveCalories ?? this.healthActiveCalories,
      netCalories: netCalories ?? this.netCalories,
      meals: meals ?? this.meals,
    );
  }
}
