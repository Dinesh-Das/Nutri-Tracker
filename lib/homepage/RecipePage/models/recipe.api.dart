import 'dart:convert';
import 'recipe.dart';
import 'package:http/http.dart' as http;

class RecipeApi {
  static Future<List<Recipe>> getRecipe() async {
    final uri = Uri.https(
      'www.themealdb.com',
      '/api/json/v1/1/filter.php',
      {'a': 'Indian'},
    );

    final response = await http.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Recipe request failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
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
