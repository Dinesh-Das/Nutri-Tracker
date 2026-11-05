class MealPlan {
  MealPlan({required this.days});

  final List<MealPlanDay> days;

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    final days = json['days'];
    if (days is! List || days.isEmpty || days.any((day) => day is! Map)) {
      throw const FormatException(
          'Meal plan must contain complete day objects.');
    }
    return MealPlan(
      days: days
          .map((day) =>
              MealPlanDay.fromJson(Map<String, dynamic>.from(day as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'days': days.map((day) => day.toJson()).toList(),
      };
}

class MealPlanDay {
  MealPlanDay({
    required this.day,
    required this.totalCalories,
    required this.meals,
  });

  final int day;
  final int totalCalories;
  final Map<String, PlannedMeal> meals;

  factory MealPlanDay.fromJson(Map<String, dynamic> json) {
    final rawDay = json['day'];
    final meals = json['meals'];
    if (rawDay is! num ||
        !rawDay.isFinite ||
        rawDay < 1 ||
        rawDay != rawDay.toInt() ||
        meals is! Map ||
        meals.isEmpty ||
        meals.values.any((meal) => meal is! Map)) {
      throw const FormatException(
          'Meal day must have a positive day number and complete meals.');
    }
    final rawMeals = Map<String, dynamic>.from(meals);
    return MealPlanDay(
      day: rawDay.toInt(),
      totalCalories:
          _nutritionNumber(json['totalCalories'], 'totalCalories').toInt(),
      meals: rawMeals.map(
        (key, value) => MapEntry(
          key,
          PlannedMeal.fromJson(Map<String, dynamic>.from(value as Map)),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'day': day,
        'totalCalories': totalCalories,
        'meals': meals.map((key, value) => MapEntry(key, value.toJson())),
      };
}

class PlannedMeal {
  PlannedMeal({
    required this.name,
    required this.calories,
    required this.description,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
  });

  final String name;
  final int calories;
  final String description;
  final double protein;
  final double carbs;
  final double fat;

  factory PlannedMeal.fromJson(Map<String, dynamic> json) {
    return PlannedMeal(
      name: json['name']?.toString() ?? '',
      calories: _nutritionNumber(json['calories'], 'calories').toInt(),
      description:
          json['description']?.toString() ?? json['prep']?.toString() ?? '',
      protein: _nutritionNumber(json['protein'], 'protein'),
      carbs: _nutritionNumber(json['carbs'], 'carbs'),
      fat: _nutritionNumber(json['fat'], 'fat'),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'description': description,
      };
}

typedef MealPlanMeal = PlannedMeal;

double _nutritionNumber(dynamic value, String field) {
  if (value == null) return 0;
  if (value is! num || !value.isFinite || value < 0) {
    throw FormatException('$field must be a finite nonnegative number.');
  }
  return value.toDouble();
}
