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
}

class MealPlanDay {
  MealPlanDay({
    required this.day,
    required this.totalCalories,
    required this.meals,
  });

  final int day;
  final int totalCalories;
  final Map<String, MealPlanMeal> meals;

  factory MealPlanDay.fromJson(Map<String, dynamic> json) {
    final rawMeals = Map<String, dynamic>.from(json['meals'] ?? {});
    return MealPlanDay(
      day: (json['day'] as num?)?.toInt() ?? 1,
      totalCalories: (json['totalCalories'] as num?)?.toInt() ?? 0,
      meals: rawMeals.map(
        (key, value) => MapEntry(
          key,
          MealPlanMeal.fromJson(Map<String, dynamic>.from(value)),
        ),
      ),
    );
  }
}

class MealPlanMeal {
  MealPlanMeal({
    required this.name,
    required this.calories,
    required this.description,
  });

  final String name;
  final int calories;
  final String description;

  factory MealPlanMeal.fromJson(Map<String, dynamic> json) {
    return MealPlanMeal(
      name: json['name'] ?? '',
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      description: json['description'] ?? '',
    );
  }
}
