import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nutri_tracker/models/indian_recipe.dart';

class RecipeApiService {
  static const _base = 'https://www.themealdb.com/api/json/v1/1/';

  Future<List<IndianRecipe>> fetchIndianRecipes() async {
    final response = await http.get(Uri.parse('${_base}filter.php?a=Indian'));
    _throwIfBad(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return ((data['meals'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(IndianRecipe.summaryFromJson)
        .toList();
  }

  Future<List<IndianRecipe>> searchRecipes(String query) async {
    final response =
        await http.get(Uri.parse('${_base}search.php?s=${Uri.encodeQueryComponent(query)}'));
    _throwIfBad(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return ((data['meals'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(IndianRecipe.fromJson)
        .toList();
  }

  Future<IndianRecipe?> getRecipeById(String id) async {
    final response = await http.get(Uri.parse('${_base}lookup.php?i=$id'));
    _throwIfBad(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
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

  void _throwIfBad(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Recipe request failed: ${response.statusCode}');
    }
  }
}
