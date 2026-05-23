import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:nutri_tracker/models/meal_entry.dart';

class CalorieService {
  CalorieService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  String dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  Stream<DailyCalorieLog> watchDailyLog(String uid, DateTime date) {
    final key = dateKey(date);
    return _firestore
        .collection('calorie_logs')
        .doc(uid)
        .collection('daily')
        .doc(key)
        .snapshots()
        .map((doc) => DailyCalorieLog.fromMap(key, doc.data()));
  }

  Future<DailyCalorieLog> getDailyLog(String uid, DateTime date) async {
    final key = dateKey(date);
    final doc = await _firestore
        .collection('calorie_logs')
        .doc(uid)
        .collection('daily')
        .doc(key)
        .get();
    return DailyCalorieLog.fromMap(key, doc.data());
  }

  Future<void> addMealEntry(String uid, DateTime date, MealEntry entry) async {
    final key = dateKey(date);
    final ref = _firestore
        .collection('calorie_logs')
        .doc(uid)
        .collection('daily')
        .doc(key);
    await ref.set({
      'totalCalories': FieldValue.increment(entry.calories),
      'totalProtein': FieldValue.increment(entry.protein),
      'totalCarbs': FieldValue.increment(entry.carbs),
      'totalFat': FieldValue.increment(entry.fat),
      'meals': FieldValue.arrayUnion([entry.toMap()]),
      'date': key,
      'uid': uid,
    }, SetOptions(merge: true));
  }

  Future<void> updateWaterIntake(String uid, DateTime date, int cups) async {
    final key = dateKey(date);
    await _firestore
        .collection('calorie_logs')
        .doc(uid)
        .collection('daily')
        .doc(key)
        .set({
      'waterIntakeMl': cups * 250,
      'date': key,
      'uid': uid,
    }, SetOptions(merge: true));
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> searchIndianFoods(String query) {
    var ref = _firestore.collection('indian_foods').limit(20);
    final trimmed = query.trim();
    if (trimmed.isEmpty) return ref.snapshots();
    return _firestore
        .collection('indian_foods')
        .orderBy('name')
        .startAt([trimmed])
        .endAt(['$trimmed\uf8ff'])
        .limit(20)
        .snapshots();
  }
}
