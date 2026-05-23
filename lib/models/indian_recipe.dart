class IndianRecipe {
  IndianRecipe({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.thumbnailUrl,
    required this.ingredients,
    this.youtubeUrl,
    this.tags,
    this.estimatedCalories,
    this.estimatedProtein,
    this.estimatedCarbs,
    this.estimatedFat,
  });

  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String thumbnailUrl;
  final String? youtubeUrl;
  final List<RecipeIngredient> ingredients;
  final String? tags;
  int? estimatedCalories;
  double? estimatedProtein;
  double? estimatedCarbs;
  double? estimatedFat;

  factory IndianRecipe.fromJson(Map<String, dynamic> json) {
    final ingredients = <RecipeIngredient>[];
    for (var i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add(
          RecipeIngredient(
            name: ingredient.toString().trim(),
            measure: measure?.toString().trim() ?? '',
          ),
        );
      }
    }
    return IndianRecipe(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      category: json['strCategory'] ?? '',
      area: json['strArea'] ?? '',
      instructions: json['strInstructions'] ?? '',
      thumbnailUrl: json['strMealThumb'] ?? '',
      youtubeUrl: json['strYoutube'],
      ingredients: ingredients,
      tags: json['strTags'],
    );
  }

  factory IndianRecipe.summaryFromJson(Map<String, dynamic> json) {
    return IndianRecipe(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      category: '',
      area: 'Indian',
      instructions: '',
      thumbnailUrl: json['strMealThumb'] ?? '',
      ingredients: const [],
    );
  }
}

class RecipeIngredient {
  const RecipeIngredient({required this.name, required this.measure});

  final String name;
  final String measure;
}
