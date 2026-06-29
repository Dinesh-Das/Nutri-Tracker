import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:nutri_tracker/models/food_item.dart';
import 'package:nutri_tracker/models/meal_entry.dart';

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
      transaction.set(ref, saved.toMap());
      transaction.set(
        _dailyRef(uid, key),
        {
          'uid': uid,
          'date': key,
          'updatedAt': Timestamp.fromDate(now),
          ..._mealDelta(saved),
        },
        SetOptions(merge: true),
      );
    });
    await _saveRecentFood(uid, FoodItem.fromMap('', saved.toMap()));
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
      final now = DateTime.now();
      final saved = entry.copyWith(
        uid: uid,
        dateKey: key,
        updatedAt: now,
      );
      transaction.set(ref, saved.toMap(), SetOptions(merge: true));
      transaction.set(
        _dailyRef(uid, key),
        {
          'uid': uid,
          'date': key,
          'updatedAt': Timestamp.fromDate(now),
          ..._mealDelta(saved, oldEntry: oldEntry),
        },
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
      transaction.delete(ref);
      transaction.set(
        _dailyRef(uid, key),
        {
          'uid': uid,
          'date': key,
          'updatedAt': Timestamp.now(),
          ..._mealDelta(
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
              oldEntry: oldEntry),
        },
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
    final legacyMeals = {
      for (final meal in base.meals)
        if (meal.id.isNotEmpty) meal.id: meal,
    };
    final documentMeals = mealsSnapshot.docs.map((doc) {
      return MealEntry.fromMap({
        ...doc.data(),
        'id': doc.id,
        'uid': uid,
        'dateKey': key,
      });
    });
    for (final meal in documentMeals) {
      legacyMeals[meal.id] = meal;
    }
    return base.copyWith(meals: legacyMeals.values.toList());
  }

  Map<String, dynamic> _mealDelta(
    MealEntry newEntry, {
    MealEntry? oldEntry,
  }) {
    final old = oldEntry;
    return {
      'totalCalories':
          FieldValue.increment(newEntry.calories - (old?.calories ?? 0)),
      'totalProtein':
          FieldValue.increment(newEntry.protein - (old?.protein ?? 0)),
      'totalCarbs': FieldValue.increment(newEntry.carbs - (old?.carbs ?? 0)),
      'totalFat': FieldValue.increment(newEntry.fat - (old?.fat ?? 0)),
      'totalFiber': FieldValue.increment(newEntry.fiber - (old?.fiber ?? 0)),
      'totalSugar': FieldValue.increment(newEntry.sugar - (old?.sugar ?? 0)),
      'totalSodium': FieldValue.increment(newEntry.sodium - (old?.sodium ?? 0)),
      'netCalories':
          FieldValue.increment(newEntry.calories - (old?.calories ?? 0)),
    };
  }

  CollectionReference<Map<String, dynamic>> _foodItems(
    String collection,
    String uid,
  ) {
    return _firestore.collection(collection).doc(uid).collection('items');
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
