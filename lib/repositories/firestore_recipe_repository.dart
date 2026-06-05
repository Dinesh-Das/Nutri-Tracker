import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_tracker/models/indian_recipe.dart';
import 'package:nutri_tracker/repositories/i_recipe_repository.dart';
import 'package:nutri_tracker/services/recipe_api_service.dart';

final recipeRepositoryProvider = Provider<IRecipeRepository>((ref) {
  return FirestoreRecipeRepository(RecipeApiService());
});

class FirestoreRecipeRepository implements IRecipeRepository {
  FirestoreRecipeRepository(this._service);

  final RecipeApiService _service;

  @override
  Future<List<IndianRecipe>> fetchIndianRecipes() {
    return _service.fetchIndianRecipes();
  }

  @override
  Future<IndianRecipe?> getRecipeById(String id) {
    return _service.getRecipeById(id);
  }

  @override
  Future<IndianRecipe?> randomIndianRecipe() {
    return _service.randomIndianRecipe();
  }

  @override
  Future<List<IndianRecipe>> searchRecipes(String query) {
    return _service.searchRecipes(query);
  }
}
