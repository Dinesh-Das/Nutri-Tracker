import 'package:cloud_firestore/cloud_firestore.dart';

enum NutritionBasis { per100g, perServing }

class ServingOption {
  const ServingOption({
    required this.label,
    required this.quantity,
    required this.unit,
    this.gramEquivalent,
  });

  final String label;
  final double quantity;
  final String unit;
  final double? gramEquivalent;

  factory ServingOption.fromMap(Map<String, dynamic> map) {
    return ServingOption(
      label: map['label']?.toString() ?? 'Serving',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 1,
      unit: map['unit']?.toString() ?? 'serving',
      gramEquivalent: (map['gramEquivalent'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'quantity': quantity,
      'unit': unit,
      'gramEquivalent': gramEquivalent,
    }..removeWhere((key, value) => value == null);
  }
}

class FoodItem {
  FoodItem({
    required this.id,
    this.uid,
    required this.name,
    this.brand = '',
    this.nutritionBasis = NutritionBasis.per100g,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.fiberPer100g = 0,
    this.sugarPer100g = 0,
    this.sodiumPer100g = 0,
    this.defaultServingQuantity = 100,
    this.defaultServingUnit = 'grams',
    this.servingOptions = const [],
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
  final NutritionBasis nutritionBasis;
  // Legacy field names are retained in Firestore. nutritionBasis explicitly
  // identifies whether these values describe 100g or the default serving.
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double fiberPer100g;
  final double sugarPer100g;
  final double sodiumPer100g;
  final double defaultServingQuantity;
  final String defaultServingUnit;
  final List<ServingOption> servingOptions;
  final String dietType;
  final String cuisine;
  final bool isCustom;
  final bool isFavourite;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get nutritionBasisLabel => nutritionBasis == NutritionBasis.per100g
      ? '100g'
      : '$defaultServingQuantity $defaultServingUnit';

  double portionFactor(ServingOption option, double quantity) {
    if (!quantity.isFinite || quantity <= 0) {
      throw ArgumentError('Quantity must be a positive finite number.');
    }
    if (nutritionBasis == NutritionBasis.perServing) {
      if (!defaultServingQuantity.isFinite ||
          defaultServingQuantity <= 0 ||
          option.unit != defaultServingUnit) {
        throw ArgumentError('This food has no known gram equivalent.');
      }
      return quantity / defaultServingQuantity;
    }
    final unit = option.unit.toLowerCase();
    if (['g', 'gram', 'grams', 'ml'].contains(unit)) return quantity / 100;
    final grams = option.gramEquivalent;
    if (grams != null && grams > 0 && option.quantity > 0) {
      return grams * quantity / option.quantity / 100;
    }
    throw ArgumentError('Choose a serving with a known gram equivalent.');
  }

  factory FoodItem.fromMap(String id, Map<String, dynamic> map) {
    return FoodItem(
      id: id,
      uid: map['uid']?.toString(),
      name: map['name']?.toString() ?? map['foodName']?.toString() ?? '',
      brand: map['brand']?.toString() ?? '',
      nutritionBasis: switch (map['nutritionBasis']) {
        null || 'per100g' => NutritionBasis.per100g,
        'perServing' => NutritionBasis.perServing,
        _ => throw const FormatException('Unknown food nutrition basis.'),
      },
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
      servingOptions: ((map['servingOptions'] as List?) ?? const [])
          .whereType<Map>()
          .map((item) => ServingOption.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
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
      'nutritionBasis': nutritionBasis.name,
      'caloriesPer100g': caloriesPer100g,
      'proteinPer100g': proteinPer100g,
      'carbsPer100g': carbsPer100g,
      'fatPer100g': fatPer100g,
      'fiberPer100g': fiberPer100g,
      'sugarPer100g': sugarPer100g,
      'sodiumPer100g': sodiumPer100g,
      'defaultServingQuantity': defaultServingQuantity,
      'defaultServingUnit': defaultServingUnit,
      'servingOptions': servingOptions.map((option) => option.toMap()).toList(),
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
    NutritionBasis? nutritionBasis,
    double? caloriesPer100g,
    double? proteinPer100g,
    double? carbsPer100g,
    double? fatPer100g,
    double? fiberPer100g,
    double? sugarPer100g,
    double? sodiumPer100g,
    double? defaultServingQuantity,
    String? defaultServingUnit,
    List<ServingOption>? servingOptions,
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
      nutritionBasis: nutritionBasis ?? this.nutritionBasis,
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
      servingOptions: servingOptions ?? this.servingOptions,
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
