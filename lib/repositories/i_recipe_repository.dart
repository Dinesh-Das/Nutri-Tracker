import 'package:nutri_tracker/models/indian_recipe.dart';

abstract interface class IRecipeRepository {
  Future<List<IndianRecipe>> fetchIndianRecipes();

  Future<List<IndianRecipe>> searchRecipes(String query);

  Future<IndianRecipe?> randomIndianRecipe();

  Future<IndianRecipe?> getRecipeById(String id);
}
