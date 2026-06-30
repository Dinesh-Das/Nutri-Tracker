import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:nutri_tracker/models/food_item.dart';
import 'package:nutri_tracker/models/meal_entry.dart';
import 'package:nutri_tracker/models/meal_template.dart';

FoodItem foodItemFromMealEntry(MealEntry meal, String uid) {
  final factor = max(meal.quantity, 1) / 100;
  return FoodItem(
    id: '',
    uid: uid,
    name: meal.foodName,
    caloriesPer100g: meal.calories / factor,
    proteinPer100g: meal.protein / factor,
    carbsPer100g: meal.carbs / factor,
    fatPer100g: meal.fat / factor,
    fiberPer100g: meal.fiber / factor,
    sugarPer100g: meal.sugar / factor,
    sodiumPer100g: meal.sodium / factor,
    defaultServingQuantity: meal.quantity,
    defaultServingUnit: meal.unit,
    servingOptions: [
      ServingOption(
        label: meal.servingDescription ?? '${meal.quantity} ${meal.unit}',
        quantity: meal.quantity,
        unit: meal.unit,
        gramEquivalent: _gramEquivalentForMeal(meal),
      ),
    ],
  );
}

double? _gramEquivalentForMeal(MealEntry meal) {
  final unit = meal.unit.toLowerCase();
  if (unit == 'grams' || unit == 'g' || unit == 'ml') {
    return meal.quantity;
  }
  return null;
}

class NutritionRepository {
  NutritionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  String dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  DocumentReference<Map<String, dynamic>> _dailyRef(
    String uid,
    String key,
  ) {
    return _firestore
        .collection('calorie_logs')
        .doc(uid)
        .collection('daily')
        .doc(key);
  }

  CollectionReference<Map<String, dynamic>> _mealsRef(
    String uid,
    String key,
  ) {
    return _dailyRef(uid, key).collection('meals');
  }

  Stream<DailyCalorieLog> watchDailyLog(String uid, DateTime date) {
    final key = dateKey(date);
    return _dailyRef(uid, key)
        .snapshots()
        .asyncMap((doc) => _hydrateDailyLog(uid, key, doc.data()));
  }

  Future<DailyCalorieLog> getDailyLog(String uid, DateTime date) async {
    final key = dateKey(date);
    final doc = await _dailyRef(uid, key).get();
    return _hydrateDailyLog(uid, key, doc.data());
  }

  Future<List<DailyCalorieLog>> getDailyLogsInRange(
    String uid, {
    required DateTime start,
    required DateTime end,
  }) async {
    final startKey = dateKey(start);
    final endKey = dateKey(end);
    final snapshot = await _firestore
        .collection('calorie_logs')
        .doc(uid)
        .collection('daily')
        .where('date', isGreaterThanOrEqualTo: startKey)
        .where('date', isLessThanOrEqualTo: endKey)
        .orderBy('date')
        .get();
    final logs = <DailyCalorieLog>[];
    for (final doc in snapshot.docs) {
      logs.add(await _hydrateDailyLog(uid, doc.id, doc.data()));
    }
    return logs;
  }

  Future<MealEntry> addMealEntry(
    String uid,
    DateTime date,
    MealEntry entry,
  ) async {
    final key = dateKey(date);
    final ref = entry.id.isEmpty
        ? _mealsRef(uid, key).doc()
        : _mealsRef(uid, key).doc(entry.id);
    final now = DateTime.now();
    final saved = entry.copyWith(
      id: ref.id,
      uid: uid,
      dateKey: key,
      servingDescription:
          entry.servingDescription ?? '${entry.quantity} ${entry.unit}',
      createdAt: entry.createdAt,
      updatedAt: now,
    );
    await _firestore.runTransaction((transaction) async {
      final dailyRef = _dailyRef(uid, key);
      final dailyDoc = await transaction.get(dailyRef);
      transaction.set(ref, saved.toMap());
      transaction.set(
        dailyRef,
        _dailyTotalsAfter(
          dailyDoc.data(),
          _mealDeltaValues(saved),
          uid: uid,
          key: key,
          updatedAt: now,
        ),
        SetOptions(merge: true),
      );
    });
    await _saveRecentFood(uid, foodItemFromMealEntry(saved, uid));
    return saved;
  }

  Future<void> updateMealEntry(
    String uid,
    DateTime date,
    MealEntry entry,
  ) async {
    if (entry.id.isEmpty) {
      throw ArgumentError('Only document-backed meals can be updated.');
    }
    final key = dateKey(date);
    final ref = _mealsRef(uid, key).doc(entry.id);
    await _firestore.runTransaction((transaction) async {
      final oldDoc = await transaction.get(ref);
      if (!oldDoc.exists) {
        throw StateError('Meal not found.');
      }
      final oldEntry = MealEntry.fromMap({
        ...oldDoc.data()!,
        'id': oldDoc.id,
      });
      final dailyRef = _dailyRef(uid, key);
      final dailyDoc = await transaction.get(dailyRef);
      final now = DateTime.now();
      final saved = entry.copyWith(
        uid: uid,
        dateKey: key,
        updatedAt: now,
      );
      transaction.set(ref, saved.toMap(), SetOptions(merge: true));
      transaction.set(
        dailyRef,
        _dailyTotalsAfter(
          dailyDoc.data(),
          _mealDeltaValues(saved, oldEntry: oldEntry),
          uid: uid,
          key: key,
          updatedAt: now,
        ),
        SetOptions(merge: true),
      );
    });
  }

  Future<void> deleteMealEntry(
    String uid,
    DateTime date,
    MealEntry entry,
  ) async {
    if (entry.id.isEmpty) {
      throw ArgumentError('Only document-backed meals can be deleted.');
    }
    final key = dateKey(date);
    final ref = _mealsRef(uid, key).doc(entry.id);
    await _firestore.runTransaction((transaction) async {
      final oldDoc = await transaction.get(ref);
      if (!oldDoc.exists) return;
      final oldEntry = MealEntry.fromMap({
        ...oldDoc.data()!,
        'id': oldDoc.id,
      });
      final dailyRef = _dailyRef(uid, key);
      final dailyDoc = await transaction.get(dailyRef);
      final now = DateTime.now();
      transaction.delete(ref);
      transaction.set(
        dailyRef,
        _dailyTotalsAfter(
          dailyDoc.data(),
          _mealDeltaValues(
            MealEntry(
              id: oldEntry.id,
              uid: uid,
              dateKey: key,
              source: oldEntry.source,
              mealType: oldEntry.mealType,
              foodName: oldEntry.foodName,
              calories: 0,
              protein: 0,
              carbs: 0,
              fat: 0,
              quantity: oldEntry.quantity,
              unit: oldEntry.unit,
            ),
            oldEntry: oldEntry,
          ),
          uid: uid,
          key: key,
          updatedAt: now,
        ),
        SetOptions(merge: true),
      );
    });
  }

  Future<void> updateWaterIntake(
    String uid,
    DateTime date,
    int waterIntakeMl,
  ) {
    final key = dateKey(date);
    return _dailyRef(uid, key).set({
      'uid': uid,
      'date': key,
      'waterIntakeMl': waterIntakeMl,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Stream<List<MealTemplate>> watchMealTemplates(String uid) {
    return _mealTemplates(uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MealTemplate.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<MealTemplate> saveMealTemplate(
    String uid,
    MealTemplate template,
  ) async {
    final ref = template.id.isEmpty
        ? _mealTemplates(uid).doc()
        : _mealTemplates(uid).doc(template.id);
    final saved = template.copyWith(
      id: ref.id,
      uid: uid,
      updatedAt: DateTime.now(),
    );
    await ref.set(saved.toMap(), SetOptions(merge: true));
    return saved;
  }

  Future<MealTemplate> saveMealsAsTemplate({
    required String uid,
    required String name,
    required String mealType,
    required List<MealEntry> meals,
  }) {
    final template = MealTemplate.fromMeals(
      id: '',
      uid: uid,
      name: name,
      mealType: mealType,
      foods: meals,
    );
    return saveMealTemplate(uid, template);
  }

  Future<List<MealEntry>> logMealTemplate({
    required String uid,
    required DateTime date,
    required MealTemplate template,
    String? mealType,
  }) async {
    final saved = <MealEntry>[];
    for (final food in template.foods) {
      saved.add(
        await addMealEntry(
          uid,
          date,
          food.copyWith(
            id: '',
            uid: uid,
            dateKey: dateKey(date),
            mealType: mealType ?? template.mealType,
            source: 'template',
          ),
        ),
      );
    }
    return saved;
  }

  Future<void> deleteMealTemplate(String uid, String templateId) {
    return _mealTemplates(uid).doc(templateId).delete();
  }

  Stream<List<FoodItem>> watchCustomFoods(String uid) {
    return _foodItems('custom_foods', uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(_foodsFromSnapshot);
  }

  Stream<List<FoodItem>> watchRecentFoods(String uid) {
    return _foodItems('recent_foods', uid)
        .orderBy('updatedAt', descending: true)
        .limit(30)
        .snapshots()
        .map(_foodsFromSnapshot);
  }

  Stream<List<FoodItem>> watchFavouriteFoods(String uid) {
    return _foodItems('favourite_foods', uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(_foodsFromSnapshot);
  }

  Future<FoodItem> saveCustomFood(String uid, FoodItem food) async {
    final ref = food.id.isEmpty
        ? _foodItems('custom_foods', uid).doc()
        : _foodItems('custom_foods', uid).doc(food.id);
    final saved = food.copyWith(
      id: ref.id,
      uid: uid,
      isCustom: true,
      updatedAt: DateTime.now(),
    );
    await ref.set(saved.toMap(), SetOptions(merge: true));
    return saved;
  }

  Future<void> deleteCustomFood(String uid, String foodId) {
    return _foodItems('custom_foods', uid).doc(foodId).delete();
  }

  Future<void> setFavouriteFood(
    String uid,
    FoodItem food, {
    required bool isFavourite,
  }) async {
    final ref = _foodItems('favourite_foods', uid).doc(_stableFoodId(food));
    if (!isFavourite) {
      await ref.delete();
      return;
    }
    await ref.set(
      food
          .copyWith(
            id: ref.id,
            uid: uid,
            isFavourite: true,
            updatedAt: DateTime.now(),
          )
          .toMap(),
      SetOptions(merge: true),
    );
  }

  Future<DailyCalorieLog> _hydrateDailyLog(
    String uid,
    String key,
    Map<String, dynamic>? data,
  ) async {
    final base = DailyCalorieLog.fromMap(key, data);
    final mealsSnapshot = await _mealsRef(uid, key).orderBy('createdAt').get();
    if (mealsSnapshot.docs.isEmpty) return base;
    final mergedMeals = <MealEntry>[];
    final seenIds = <String>{};
    for (final meal in base.meals) {
      mergedMeals.add(meal);
      if (meal.id.isNotEmpty) seenIds.add(meal.id);
    }
    final documentMeals = mealsSnapshot.docs.map((doc) {
      return MealEntry.fromMap({
        ...doc.data(),
        'id': doc.id,
        'uid': uid,
        'dateKey': key,
      });
    });
    for (final meal in documentMeals) {
      if (seenIds.add(meal.id)) {
        mergedMeals.add(meal);
      } else {
        final index = mergedMeals.indexWhere((item) => item.id == meal.id);
        if (index >= 0) mergedMeals[index] = meal;
      }
    }
    return base.copyWith(meals: mergedMeals);
  }

  Map<String, num> _mealDeltaValues(
    MealEntry newEntry, {
    MealEntry? oldEntry,
  }) {
    final old = oldEntry;
    return {
      'totalCalories': newEntry.calories - (old?.calories ?? 0),
      'totalProtein': newEntry.protein - (old?.protein ?? 0),
      'totalCarbs': newEntry.carbs - (old?.carbs ?? 0),
      'totalFat': newEntry.fat - (old?.fat ?? 0),
      'totalFiber': newEntry.fiber - (old?.fiber ?? 0),
      'totalSugar': newEntry.sugar - (old?.sugar ?? 0),
      'totalSodium': newEntry.sodium - (old?.sodium ?? 0),
      'netCalories': newEntry.calories - (old?.calories ?? 0),
    };
  }

  Map<String, dynamic> _dailyTotalsAfter(
    Map<String, dynamic>? current,
    Map<String, num> delta, {
    required String uid,
    required String key,
    required DateTime updatedAt,
  }) {
    int nextInt(String field, {bool clampToZero = true}) {
      final value =
          ((current?[field] as num?)?.toInt() ?? 0) + delta[field]!.toInt();
      return clampToZero ? max(0, value) : value;
    }

    double nextDouble(String field) {
      final value =
          ((current?[field] as num?)?.toDouble() ?? 0) + delta[field]!;
      return max(0, value);
    }

    return {
      'uid': uid,
      'date': key,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'totalCalories': nextInt('totalCalories'),
      'totalProtein': nextDouble('totalProtein'),
      'totalCarbs': nextDouble('totalCarbs'),
      'totalFat': nextDouble('totalFat'),
      'totalFiber': nextDouble('totalFiber'),
      'totalSugar': nextDouble('totalSugar'),
      'totalSodium': nextDouble('totalSodium'),
      'netCalories': nextInt('netCalories', clampToZero: false),
    };
  }

  CollectionReference<Map<String, dynamic>> _foodItems(
    String collection,
    String uid,
  ) {
    return _firestore.collection(collection).doc(uid).collection('items');
  }

  CollectionReference<Map<String, dynamic>> _mealTemplates(String uid) {
    return _firestore
        .collection('meal_templates')
        .doc(uid)
        .collection('templates');
  }

  List<FoodItem> _foodsFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs
        .map((doc) => FoodItem.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> _saveRecentFood(String uid, FoodItem food) {
    final ref = _foodItems('recent_foods', uid).doc(_stableFoodId(food));
    return ref.set(
      food
          .copyWith(
            id: ref.id,
            uid: uid,
            updatedAt: DateTime.now(),
          )
          .toMap(),
      SetOptions(merge: true),
    );
  }

  String _stableFoodId(FoodItem food) {
    if (food.id.isNotEmpty) return food.id;
    final normalized = food.name
        .toLowerCase()
        .replaceAll(RegExp('[^a-z0-9]+'), '_')
        .replaceAll(RegExp('(^_|_\$)'), '');
    return normalized.isEmpty
        ? _firestore.collection('recent_foods').doc().id
        : normalized;
  }
}
