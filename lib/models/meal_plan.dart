class MealPlan {
  MealPlan({required this.days});

  final List<MealPlanDay> days;

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      days: ((json['days'] as List?) ?? const [])
          .whereType<Map>()
          .map((day) => MealPlanDay.fromJson(Map<String, dynamic>.from(day)))
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
    final rawMeals = Map<String, dynamic>.from(json['meals'] ?? {});
    return MealPlanDay(
      day: (json['day'] as num?)?.toInt() ?? 1,
      totalCalories: (json['totalCalories'] as num?)?.toInt() ?? 0,
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
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      description:
          json['description']?.toString() ?? json['prep']?.toString() ?? '',
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0,
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
