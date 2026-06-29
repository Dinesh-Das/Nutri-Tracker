import 'package:cloud_firestore/cloud_firestore.dart';

class FoodItem {
  FoodItem({
    required this.id,
    this.uid,
    required this.name,
    this.brand = '',
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.fiberPer100g = 0,
    this.sugarPer100g = 0,
    this.sodiumPer100g = 0,
    this.defaultServingQuantity = 100,
    this.defaultServingUnit = 'grams',
    this.dietType = 'mixed',
    this.cuisine = 'Indian',
    this.isCustom = false,
    this.isFavourite = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String? uid;
  final String name;
  final String brand;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double fiberPer100g;
  final double sugarPer100g;
  final double sodiumPer100g;
  final double defaultServingQuantity;
  final String defaultServingUnit;
  final String dietType;
  final String cuisine;
  final bool isCustom;
  final bool isFavourite;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory FoodItem.fromMap(String id, Map<String, dynamic> map) {
    return FoodItem(
      id: id,
      uid: map['uid']?.toString(),
      name: map['name']?.toString() ?? map['foodName']?.toString() ?? '',
      brand: map['brand']?.toString() ?? '',
      caloriesPer100g: (map['caloriesPer100g'] as num?)?.toDouble() ??
          (map['calories'] as num?)?.toDouble() ??
          0,
      proteinPer100g: (map['proteinPer100g'] as num?)?.toDouble() ??
          (map['protein'] as num?)?.toDouble() ??
          0,
      carbsPer100g: (map['carbsPer100g'] as num?)?.toDouble() ??
          (map['carbs'] as num?)?.toDouble() ??
          0,
      fatPer100g: (map['fatPer100g'] as num?)?.toDouble() ??
          (map['fat'] as num?)?.toDouble() ??
          0,
      fiberPer100g: (map['fiberPer100g'] as num?)?.toDouble() ??
          (map['fiber'] as num?)?.toDouble() ??
          0,
      sugarPer100g: (map['sugarPer100g'] as num?)?.toDouble() ??
          (map['sugar'] as num?)?.toDouble() ??
          0,
      sodiumPer100g: (map['sodiumPer100g'] as num?)?.toDouble() ??
          (map['sodium'] as num?)?.toDouble() ??
          0,
      defaultServingQuantity:
          (map['defaultServingQuantity'] as num?)?.toDouble() ??
              (map['quantity'] as num?)?.toDouble() ??
              100,
      defaultServingUnit: map['defaultServingUnit']?.toString() ??
          map['unit']?.toString() ??
          'grams',
      dietType: map['dietType']?.toString() ?? 'mixed',
      cuisine: map['cuisine']?.toString() ?? 'Indian',
      isCustom: map['isCustom'] == true,
      isFavourite: map['isFavourite'] == true,
      createdAt: _toDate(map['createdAt']),
      updatedAt: _toDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'brand': brand,
      'caloriesPer100g': caloriesPer100g,
      'proteinPer100g': proteinPer100g,
      'carbsPer100g': carbsPer100g,
      'fatPer100g': fatPer100g,
      'fiberPer100g': fiberPer100g,
      'sugarPer100g': sugarPer100g,
      'sodiumPer100g': sodiumPer100g,
      'defaultServingQuantity': defaultServingQuantity,
      'defaultServingUnit': defaultServingUnit,
      'dietType': dietType,
      'cuisine': cuisine,
      'isCustom': isCustom,
      'isFavourite': isFavourite,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'searchName': name.toLowerCase(),
    }..removeWhere((key, value) => value == null);
  }

  FoodItem copyWith({
    String? id,
    String? uid,
    String? name,
    String? brand,
    double? caloriesPer100g,
    double? proteinPer100g,
    double? carbsPer100g,
    double? fatPer100g,
    double? fiberPer100g,
    double? sugarPer100g,
    double? sodiumPer100g,
    double? defaultServingQuantity,
    String? defaultServingUnit,
    String? dietType,
    String? cuisine,
    bool? isCustom,
    bool? isFavourite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FoodItem(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
      proteinPer100g: proteinPer100g ?? this.proteinPer100g,
      carbsPer100g: carbsPer100g ?? this.carbsPer100g,
      fatPer100g: fatPer100g ?? this.fatPer100g,
      fiberPer100g: fiberPer100g ?? this.fiberPer100g,
      sugarPer100g: sugarPer100g ?? this.sugarPer100g,
      sodiumPer100g: sodiumPer100g ?? this.sodiumPer100g,
      defaultServingQuantity:
          defaultServingQuantity ?? this.defaultServingQuantity,
      defaultServingUnit: defaultServingUnit ?? this.defaultServingUnit,
      dietType: dietType ?? this.dietType,
      cuisine: cuisine ?? this.cuisine,
      isCustom: isCustom ?? this.isCustom,
      isFavourite: isFavourite ?? this.isFavourite,
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
