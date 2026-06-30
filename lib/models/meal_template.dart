import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutri_tracker/models/meal_entry.dart';

class MealTemplate {
  MealTemplate({
    required this.id,
    required this.uid,
    required this.name,
    required this.mealType,
    this.foods = const [],
    this.totalCalories = 0,
    this.totalProtein = 0,
    this.totalCarbs = 0,
    this.totalFat = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String uid;
  final String name;
  final String mealType;
  final List<MealEntry> foods;
  final int totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory MealTemplate.fromMap(String id, Map<String, dynamic> map) {
    return MealTemplate(
      id: id,
      uid: map['uid']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      mealType: map['mealType']?.toString() ?? 'snack',
      foods: ((map['foods'] as List?) ?? const [])
          .whereType<Map>()
          .map((item) => MealEntry.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      totalCalories: (map['totalCalories'] as num?)?.toInt() ?? 0,
      totalProtein: (map['totalProtein'] as num?)?.toDouble() ?? 0,
      totalCarbs: (map['totalCarbs'] as num?)?.toDouble() ?? 0,
      totalFat: (map['totalFat'] as num?)?.toDouble() ?? 0,
      createdAt: _toDate(map['createdAt']),
      updatedAt: _toDate(map['updatedAt']),
    );
  }

  factory MealTemplate.fromMeals({
    required String id,
    required String uid,
    required String name,
    required String mealType,
    required List<MealEntry> foods,
  }) {
    return MealTemplate(
      id: id,
      uid: uid,
      name: name,
      mealType: mealType,
      foods: foods,
      totalCalories: foods.fold<int>(0, (total, meal) => total + meal.calories),
      totalProtein:
          foods.fold<double>(0, (total, meal) => total + meal.protein),
      totalCarbs: foods.fold<double>(0, (total, meal) => total + meal.carbs),
      totalFat: foods.fold<double>(0, (total, meal) => total + meal.fat),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'mealType': mealType,
      'foods': foods.map((meal) => meal.toMap()).toList(),
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  MealTemplate copyWith({
    String? id,
    String? uid,
    String? name,
    String? mealType,
    List<MealEntry>? foods,
    int? totalCalories,
    double? totalProtein,
    double? totalCarbs,
    double? totalFat,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MealTemplate(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      mealType: mealType ?? this.mealType,
      foods: foods ?? this.foods,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
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
