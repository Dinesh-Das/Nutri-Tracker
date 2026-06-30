import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutri_tracker/database/user_model.dart';
import 'package:nutri_tracker/models/achievement.dart';
import 'package:nutri_tracker/models/favourite_item.dart';
import 'package:nutri_tracker/models/weight_entry.dart';
import 'package:nutri_tracker/services/achievement_service.dart';
import 'package:nutri_tracker/services/daily_summary_service.dart';
import 'package:nutri_tracker/services/health_service.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  Stream<UserModel> watchUser(String uid) {
    return _firestore
        .collection('user_details')
        .doc(uid)
        .snapshots()
        .map((doc) => UserModel.fromMap(doc.data()));
  }

  Future<UserModel> getUser(String uid) async {
    final doc = await _firestore.collection('user_details').doc(uid).get();
    return UserModel.fromMap(doc.data());
  }

  Future<bool> isCurrentUserAdmin() async {
    final uid = currentUid;
    if (uid == null) return false;
    final user = await getUser(uid);
    return user.isAdmin == true;
  }

  Future<void> saveBmiRecord({
    required String uid,
    required double bmi,
    required double weight,
    required double height,
    required String gender,
    required double bmr,
    int? dailyCalorieGoal,
    String? activityLevel,
  }) async {
    await _firestore.collection('user_details').doc(uid).set({
      'uid': uid,
      'bmi': bmi,
      'weight': weight.toStringAsFixed(1),
      'height': height.toStringAsFixed(0),
      'gender': gender,
      'bmr': bmr,
      'dailyCalorieGoal': dailyCalorieGoal,
      'activityLevel': activityLevel,
      'lastBmiDate': Timestamp.now(),
    }, SetOptions(merge: true));

    await _firestore
        .collection('weight_logs')
        .doc(uid)
        .collection('entries')
        .add({
      'weight': weight,
      'bmi': bmi,
      'date': Timestamp.now(),
      'note': '',
    });
    await DailySummaryService(firestore: _firestore)
        .rebuildSummary(uid, DateTime.now());
    try {
      await HealthService().writeWeightEntry(weight, DateTime.now());
    } catch (_) {}
    if (bmi >= 18.5 && bmi < 25) {
      try {
        await AchievementService().checkAndAward(
          uid,
          AchievementType.bmiNormal,
        );
      } catch (_) {}
    }
  }

  Future<List<WeightEntry>> getWeightHistory(String uid) async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final snapshot = await _firestore
        .collection('weight_logs')
        .doc(uid)
        .collection('entries')
        .where('date', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
        .orderBy('date')
        .get();
    return snapshot.docs.map((doc) => WeightEntry.fromMap(doc.data())).toList();
  }

  Stream<List<FavouriteItem>> watchFavourites(String uid) {
    return _firestore
        .collection('user_details')
        .doc(uid)
        .collection('favourites')
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FavouriteItem.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> saveFavourite(String uid, FavouriteItem item) {
    return _firestore
        .collection('user_details')
        .doc(uid)
        .collection('favourites')
        .doc(item.id)
        .set(item.toMap());
  }

  Future<void> removeFavourite(String uid, String id) {
    return _firestore
        .collection('user_details')
        .doc(uid)
        .collection('favourites')
        .doc(id)
        .delete();
  }
}
