import 'recipe.dart';
import 'package:dio/dio.dart';

class RecipeApi {
  static Future<List<Recipe>> getRecipe() async {
    final response = await Dio().get<Map<String, dynamic>>(
      'https://www.themealdb.com/api/json/v1/1/filter.php',
      queryParameters: {'a': 'Indian'},
    );
    final statusCode = response.statusCode ?? 500;
    if (statusCode < 200 || statusCode >= 300) {
      throw Exception('Recipe request failed: ${response.statusCode}');
    }

    final data = response.data ?? const <String, dynamic>{};
    final meals = (data['meals'] as List?) ?? const [];

    return meals
        .whereType<Map<String, dynamic>>()
        .map((meal) => Recipe(
              name: (meal['strMeal'] ?? '').toString(),
              images: (meal['strMealThumb'] ?? '').toString(),
              rating: 0,
              totalTime: 'Indian',
            ))
        .toList();
  }
}
