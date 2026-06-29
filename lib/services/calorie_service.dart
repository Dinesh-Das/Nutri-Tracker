import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:nutri_tracker/models/achievement.dart';
import 'package:nutri_tracker/models/meal_entry.dart';
import 'package:nutri_tracker/repositories/nutrition_repository.dart';
import 'package:nutri_tracker/services/achievement_service.dart';
import 'package:nutri_tracker/services/health_service.dart';
import 'package:nutri_tracker/services/widget_sync_service.dart';

class CalorieService {
  CalorieService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _nutritionRepository = NutritionRepository(
            firestore: firestore ?? FirebaseFirestore.instance);

  final FirebaseFirestore _firestore;
  final NutritionRepository _nutritionRepository;

  String dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  Stream<DailyCalorieLog> watchDailyLog(String uid, DateTime date) {
    return _nutritionRepository.watchDailyLog(uid, date);
  }

  Future<DailyCalorieLog> getDailyLog(String uid, DateTime date) async {
    return _nutritionRepository.getDailyLog(uid, date);
  }

  Future<List<DailyCalorieLog>> getDailyLogsInRange(
    String uid, {
    required DateTime start,
    required DateTime end,
  }) async {
    return _nutritionRepository.getDailyLogsInRange(
      uid,
      start: start,
      end: end,
    );
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
    await _nutritionRepository.addMealEntry(uid, date, entry);
    try {
      final log = await getDailyLog(uid, date);
      final user = await _firestore.collection('user_details').doc(uid).get();
      final dailyGoal =
          (user.data()?['dailyCalorieGoal'] as num?)?.toInt() ?? 2000;
      await const WidgetSyncService().syncMealLog(
        log: log,
        dailyGoal: dailyGoal,
      );
    } catch (_) {}
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
    await _nutritionRepository.updateWaterIntake(uid, date, cups * 250);
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
