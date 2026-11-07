import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AccountDeletionService {
  AccountDeletionService(
      {FirebaseFirestore? firestore,
      Future<void> Function(String uid)? deleteFiles})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _deleteFiles = deleteFiles ?? deleteOwnedFiles;

  final FirebaseFirestore _firestore;
  final Future<void> Function(String uid) _deleteFiles;

  Future<void> deleteAccount(
      {required String uid,
      required Future<void> Function() deleteAuthUser}) async {
    if (uid.isEmpty || uid.contains('/'))
      throw ArgumentError('Invalid user ID.');
    // Group queries find nested records even when their daily parent never
    // existed (workout mirrors) or was removed by an older account cleanup.
    for (final group in ['meals', 'sessions']) {
      await _deleteQuery(
          _firestore.collectionGroup(group).where('uid', isEqualTo: uid),
          ownsPath: (path) {
        final parts = path.split('/');
        if (parts[1] != uid) return false;
        if (group == 'meals') {
          return parts.length == 6 &&
              parts[0] == 'calorie_logs' &&
              parts[2] == 'daily' &&
              parts[4] == 'meals';
        }
        return parts[0] == 'workout_logs' &&
            ((parts.length == 4 && parts[2] == 'sessions') ||
                (parts.length == 6 &&
                    parts[2] == 'daily' &&
                    parts[4] == 'sessions'));
      });
    }
    for (final path in [
      'user_details/$uid/favourites',
      'user_details/$uid/mealPlans',
      'calorie_logs/$uid/daily',
      'weight_logs/$uid/entries',
      'ai_chats/$uid/messages',
      'workout_logs/$uid/entries',
      'user_goals/$uid/goals',
      'user_workout_programs/$uid/programs',
      'meal_templates/$uid/templates',
      'custom_workout_programs/$uid/programs',
      'custom_foods/$uid/items',
      'favourite_foods/$uid/items',
      'recent_foods/$uid/items',
      'daily_summaries/$uid/daily',
      'achievements/$uid/items',
    ]) {
      await _deleteQuery(_firestore.collection(path));
    }
    for (final root in [
      'calorie_logs',
      'weight_logs',
      'ai_chats',
      'workout_logs',
      'user_goals',
      'user_workout_programs',
      'achievements'
    ]) {
      await _firestore.doc('$root/$uid').delete();
    }
    await _deleteFiles(uid);
    await _firestore.doc('user_details/$uid').delete();
    await deleteAuthUser();
  }

  Future<void> _deleteQuery(Query<Map<String, dynamic>> query,
      {bool Function(String path)? ownsPath}) async {
    while (true) {
      final snapshot = await query.limit(400).get();
      if (snapshot.docs.isEmpty) return;
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        if (ownsPath != null && !ownsPath(doc.reference.path)) {
          throw StateError(
              'Account cleanup encountered a record outside its owner path.');
        }
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}

Future<void> deleteOwnedFiles(String uid) async {
  for (final root in ['images', 'profile_images', 'food_photos']) {
    await deleteStorageTree(FirebaseStorage.instance.ref('$root/$uid'));
  }
}

Future<void> deleteStorageTree(Reference directory) async {
  final listing = await directory.listAll();
  for (final prefix in listing.prefixes) {
    await deleteStorageTree(prefix);
  }
  for (final item in listing.items) {
    try {
      await item.delete();
    } on FirebaseException catch (error) {
      if (error.code != 'object-not-found') rethrow;
    }
  }
}
