import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:nutri_tracker/models/achievement.dart';
import 'package:nutri_tracker/models/meal_entry.dart';
import 'package:nutri_tracker/services/achievement_service.dart';
import 'package:nutri_tracker/services/health_service.dart';

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

    return snapshot.docs
        .map((doc) => DailyCalorieLog.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<int> getLogStreak(String uid) async {
    final thirtyDaysAgoKey =
        dateKey(DateTime.now().subtract(const Duration(days: 29)));
    final snapshot = await _firestore
        .collection('calorie_logs')
        .doc(uid)
        .collection('daily')
        .where('date', isGreaterThanOrEqualTo: thirtyDaysAgoKey)
        .orderBy('date', descending: true)
        .limit(30)
        .get();

    var streak = 0;
    var expected = DateTime.now();
    for (final doc in snapshot.docs) {
      final docDate = DateTime.tryParse(doc.data()['date'] as String? ?? '');
      final calories = (doc.data()['totalCalories'] as num?)?.toInt() ?? 0;
      if (docDate == null || calories <= 0 || !_isSameDay(docDate, expected)) {
        break;
      }
      streak++;
      expected = expected.subtract(const Duration(days: 1));
    }
    return streak;
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
    try {
      final streak = await getLogStreak(uid);
      if (streak >= 30) {
        await AchievementService().checkAndAward(
          uid,
          AchievementType.logStreak30,
        );
      } else if (streak >= 7) {
        await AchievementService().checkAndAward(
          uid,
          AchievementType.logStreak7,
        );
      }
    } catch (_) {}
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
    try {
      await HealthService().writeWaterIntake(cups * 250, date);
    } catch (_) {}
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> searchIndianFoods(String query) {
    var ref = _firestore.collection('indian_foods').orderBy('name').limit(20);
    final trimmed = query.trim();
    if (trimmed.isEmpty) return ref.snapshots();
    final normalized = trimmed.toLowerCase();
    return _firestore
        .collection('indian_foods')
        .orderBy('searchName')
        .startAt([normalized])
        .endAt(['$normalized\uf8ff'])
        .limit(20)
        .snapshots();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
