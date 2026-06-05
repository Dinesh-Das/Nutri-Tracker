import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nutri_tracker/models/meal_entry.dart';

class BarcodeService {
  BarcodeService({Dio? dio}) : _dio = dio ?? Dio();

  static const _cacheBox = 'barcode_cache';

  final Dio _dio;

  Future<MealEntry?> lookupBarcode(
    String code, {
    String mealType = 'snack',
  }) async {
    final barcode = code.trim();
    if (barcode.isEmpty) return null;

    final box = await Hive.openBox(_cacheBox);
    final cached = box.get(barcode);
    if (cached is Map) {
      return MealEntry.fromMap(
        Map<String, dynamic>.from(cached)..['mealType'] = mealType,
      );
    }

    final response = await _dio.get<Map<String, dynamic>>(
      'https://world.openfoodfacts.org/api/v2/product/$barcode.json',
      queryParameters: {
        'fields':
            'product_name,nutriments,quantity,serving_size,brands,countries_tags',
      },
    );
    final data = response.data;
    if (data == null || data['status'] == 0) return null;

    final product = Map<String, dynamic>.from(data['product'] as Map? ?? {});
    final nutriments =
        Map<String, dynamic>.from(product['nutriments'] as Map? ?? {});
    final entry = MealEntry(
      mealType: mealType,
      foodName: _productName(product, barcode),
      calories: _numValue(nutriments['energy-kcal_100g']).round(),
      protein: _numValue(nutriments['proteins_100g']),
      carbs: _numValue(nutriments['carbohydrates_100g']),
      fat: _numValue(nutriments['fat_100g']),
      quantity: 100,
      unit: 'grams',
    );
    await box.put(barcode, {
      'mealType': entry.mealType,
      'foodName': entry.foodName,
      'calories': entry.calories,
      'protein': entry.protein,
      'carbs': entry.carbs,
      'fat': entry.fat,
      'quantity': entry.quantity,
      'unit': entry.unit,
    });
    return entry;
  }

  String _productName(Map<String, dynamic> product, String barcode) {
    final name = product['product_name']?.toString().trim();
    if (name != null && name.isNotEmpty) return name;
    final brands = product['brands']?.toString().trim();
    if (brands != null && brands.isNotEmpty) return brands;
    return 'Packaged food $barcode';
  }

  double _numValue(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
