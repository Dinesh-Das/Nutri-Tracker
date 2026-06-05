import 'package:dio/dio.dart';
import 'package:nutri_tracker/models/indian_recipe.dart';

class RecipeApiService {
  static const _base = 'https://www.themealdb.com/api/json/v1/1/';

  RecipeApiService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<List<IndianRecipe>> fetchIndianRecipes() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${_base}filter.php',
      queryParameters: {'a': 'Indian'},
    );
    _throwIfBad(response);
    final data = response.data ?? const <String, dynamic>{};
    return ((data['meals'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(IndianRecipe.summaryFromJson)
        .toList();
  }

  Future<List<IndianRecipe>> searchRecipes(String query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${_base}search.php',
      queryParameters: {'s': query},
    );
    _throwIfBad(response);
    final data = response.data ?? const <String, dynamic>{};
    return ((data['meals'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(IndianRecipe.fromJson)
        .toList();
  }

  Future<IndianRecipe?> getRecipeById(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${_base}lookup.php',
      queryParameters: {'i': id},
    );
    _throwIfBad(response);
    final data = response.data ?? const <String, dynamic>{};
    final meals = (data['meals'] as List?) ?? const [];
    if (meals.isEmpty) return null;
    return IndianRecipe.fromJson(Map<String, dynamic>.from(meals.first));
  }

  Future<IndianRecipe?> randomIndianRecipe() async {
    final indian = await fetchIndianRecipes();
    if (indian.isEmpty) return null;
    indian.shuffle();
    return getRecipeById(indian.first.id);
  }

  void _throwIfBad(Response<dynamic> response) {
    final statusCode = response.statusCode ?? 500;
    if (statusCode < 200 || statusCode >= 300) {
      throw Exception('Recipe request failed: ${response.statusCode}');
    }
  }
}
