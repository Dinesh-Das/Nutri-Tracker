import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_tracker/database/user_model.dart';
import 'package:nutri_tracker/models/indian_recipe.dart';
import 'package:nutri_tracker/models/meal_entry.dart';
import 'package:nutri_tracker/utils/health_utils.dart';

void main() {
  group('health utils', () {
    test('calculates BMI and category boundaries', () {
      final bmi = calculateBmi(70, 175);

      expect(bmi, closeTo(22.86, 0.01));
      expect(getBmiCategory(18.4), 'Underweight');
      expect(getBmiCategory(18.5), 'Normal');
      expect(getBmiCategory(25), 'Overweight');
      expect(getBmiCategory(30), 'Obese');
    });

    test('calculates BMR with the app formulas', () {
      expect(
        calculateBmr(gender: 'Male', weightKg: 70, heightCm: 175, age: 30),
        closeTo(1695.67, 0.01),
      );
      expect(activityMultiplier('moderately_active'), 1.55);
      expect(activityMultiplier(null), 1.2);
    });

    test('estimates exercise calories with MET values', () {
      expect(
        estimateCaloriesBurned(
          exercise: 'running',
          durationMinutes: 30,
          weightKg: 70,
        ),
        closeTo(360, 20),
      );
    });
  });

  group('models', () {
    test('UserModel.toMap omits protected and null fields', () {
      final map = UserModel(
        uid: 'uid-1',
        email: 'user@example.com',
        isAdmin: true,
      ).toMap();

      expect(map['uid'], 'uid-1');
      expect(map['email'], 'user@example.com');
      expect(map.containsKey('isAdmin'), isFalse);
      expect(map.containsValue(null), isFalse);
    });

    test('UserModel.fromMap parses bmi and bmr as doubles', () {
      final model = UserModel.fromMap({'bmi': 22.5, 'bmr': 1800});

      expect(model.bmi, 22.5);
      expect(model.bmr, 1800.0);
    });

    test('UserModel.fromMap keeps legacy string bmi backward-compatible', () {
      final model = UserModel.fromMap({'bmi': '22.5', 'bmr': '1800'});

      expect(model.bmi, 22.5);
      expect(model.bmr, 1800.0);
    });

    test('MealEntry serializes and parses Firestore maps', () {
      final entry = MealEntry(
        mealType: 'lunch',
        foodName: 'Rajma Chawal',
        calories: 450,
        protein: 16,
        carbs: 70,
        fat: 9,
        quantity: 250,
        unit: 'grams',
      );

      final parsed = MealEntry.fromMap(entry.toMap());

      expect(parsed.mealType, 'lunch');
      expect(parsed.foodName, 'Rajma Chawal');
      expect(parsed.calories, 450);
      expect(parsed.quantity, 250);
    });

    test('IndianRecipe parses TheMealDB ingredients', () {
      final recipe = IndianRecipe.fromJson({
        'idMeal': '52807',
        'strMeal': 'Baingan Bharta',
        'strCategory': 'Vegetarian',
        'strArea': 'Indian',
        'strInstructions': 'Roast, mash, and simmer.',
        'strMealThumb': 'https://example.com/baingan.jpg',
        'strYoutube': 'https://youtube.com/watch?v=example',
        'strIngredient1': 'Aubergine',
        'strMeasure1': '1 large',
        'strIngredient2': 'Tomato',
        'strMeasure2': '2',
        'strIngredient3': '',
      });

      expect(recipe.id, '52807');
      expect(recipe.name, 'Baingan Bharta');
      expect(recipe.ingredients, hasLength(2));
      expect(recipe.ingredients.first.name, 'Aubergine');
    });
  });
}
