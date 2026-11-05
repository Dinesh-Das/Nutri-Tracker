import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_tracker/models/meal_plan.dart';
import 'package:nutri_tracker/services/ai_service.dart';

Map<String, dynamic> validWorkoutResponse() => {
      'title': 'Starter strength',
      'description': 'A short home session.',
      'goal': 'fitness',
      'level': 'beginner',
      'durationWeeks': 4,
      'daysPerWeek': 1,
      'estimatedMinutesPerDay': 25,
      'equipment': 'none',
      'workoutDays': [
        {
          'day': 1,
          'title': 'Full body basics',
          'exerciseIds': ['squats', 'plank'],
        },
      ],
    };

void main() {
  group('AI response validation', () {
    test('rejects malformed meal days instead of returning an empty plan', () {
      expect(
        () => MealPlan.fromJson({
          'days': ['not a meal-plan day'],
        }),
        throwsFormatException,
      );
    });

    test('rejects negative nutrient values in a generated meal', () {
      expect(
        () => PlannedMeal.fromJson({
          'name': 'Dal rice',
          'calories': 450,
          'protein': -5,
          'carbs': 65,
          'fat': 12,
          'description': 'One plate.',
        }),
        throwsFormatException,
      );
    });

    test('rejects a negative generated workout duration', () {
      final response = validWorkoutResponse();
      expect(validateWorkoutProgramJson(response).estimatedMinutesPerDay, 25);
      response['estimatedMinutesPerDay'] = -20;

      expect(() => validateWorkoutProgramJson(response), throwsFormatException);
    });

    test('rejects a nonpositive generated workout day number', () {
      final response = validWorkoutResponse();
      response['workoutDays'] = [
        {
          'day': 0,
          'title': 'Full body basics',
          'exerciseIds': ['squats', 'plank'],
        },
      ];

      expect(() => validateWorkoutProgramJson(response), throwsFormatException);
    });
  });
}
