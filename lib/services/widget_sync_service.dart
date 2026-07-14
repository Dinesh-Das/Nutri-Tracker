import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:nutri_tracker/models/meal_entry.dart';

class WidgetSyncService {
  const WidgetSyncService();

  static const _androidWidgetName = 'NutriWidget';

  Future<void> syncMealLog({
    required DailyCalorieLog log,
    required int dailyGoal,
  }) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    final lastMeal = _lastMealName(log.meals);
    final remainingCalories = dailyGoal - log.totalCalories;
    final updatedAt = DateFormat.jm().format(DateTime.now());

    await HomeWidget.saveWidgetData<int>(
      'widget_total_calories',
      log.totalCalories,
    );
    await HomeWidget.saveWidgetData<int>('widget_daily_goal', dailyGoal);
    await HomeWidget.saveWidgetData<int>(
      'widget_remaining_calories',
      remainingCalories,
    );
    await HomeWidget.saveWidgetData<String>('widget_last_meal', lastMeal);
    await HomeWidget.saveWidgetData<String>(
      'widget_updated_at',
      'Updated $updatedAt',
    );
    await HomeWidget.updateWidget(androidName: _androidWidgetName);
  }

  String _lastMealName(List<MealEntry> meals) {
    if (meals.isEmpty) return 'No meal logged';
    final sorted = [...meals]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.first.foodName;
  }
}
