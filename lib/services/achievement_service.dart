import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutri_tracker/models/achievement.dart';
import 'package:nutri_tracker/services/notification_service.dart';

class AchievementService {
  AchievementService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> checkAndAward(String uid, AchievementType type) async {
    final ref = _firestore
        .collection('achievements')
        .doc(uid)
        .collection('items')
        .doc(type.name);
    final doc = await ref.get();
    if (doc.exists) return;

    final achievement = Achievement(
      type: type,
      unlockedAt: DateTime.now(),
    );
    await ref.set({
      ...achievement.toMap(),
      'uid': uid,
    });
    await NotificationService.instance.showAchievement(
      'Achievement unlocked',
      achievement.title,
    );
  }

  Stream<List<Achievement>> watchAchievements(String uid) {
    return _firestore
        .collection('achievements')
        .doc(uid)
        .collection('items')
        .orderBy('unlockedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Achievement.fromMap(doc.data()))
            .toList());
  }
}
