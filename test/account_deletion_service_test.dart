import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_tracker/services/account_deletion_service.dart';

void main() {
  const ownedPaths = [
    'user_details/u', 'user_details/u/favourites/f',
    'user_details/u/mealPlans/p',
    'calorie_logs/u/daily/2026-11-06',
    'calorie_logs/u/daily/2026-11-06/meals/m',
    // Neither parent document exists: normal workout mirrors and old deletions.
    'calorie_logs/u/daily/2026-10-01/meals/orphan',
    'workout_logs/u/entries/e', 'workout_logs/u/sessions/s',
    'workout_logs/u/daily/2026-11-06/sessions/s',
    'user_goals/u/goals/g', 'user_workout_programs/u/programs/p',
    'meal_templates/u/templates/t', 'custom_workout_programs/u/programs/p',
    'custom_foods/u/items/f', 'favourite_foods/u/items/f',
    'recent_foods/u/items/f', 'daily_summaries/u/daily/2026-11-06',
    'achievements/u/items/a', 'weight_logs/u/entries/w',
    'ai_chats/u/messages/m',
  ];

  test(
      'deletes every owned path including parentless nested records before auth',
      () async {
    final db = FakeFirebaseFirestore();
    for (final path in ownedPaths) {
      await db.doc(path).set({'uid': 'u'});
    }
    await db.doc('calorie_logs/other/daily/day/meals/m').set({'uid': 'other'});
    final events = <String>[];
    final service = AccountDeletionService(
        firestore: db,
        deleteFiles: (uid) async {
          events.add('files:$uid');
        });
    await service.deleteAccount(
        uid: 'u',
        deleteAuthUser: () async {
          for (final path in ownedPaths) {
            expect((await db.doc(path).get()).exists, isFalse, reason: path);
          }
          events.add('auth');
        });
    expect(events, ['files:u', 'auth']);
    expect((await db.doc('calorie_logs/other/daily/day/meals/m').get()).exists,
        isTrue);
    // Repeated deletion after interruption is harmless.
    await service.deleteAccount(uid: 'u', deleteAuthUser: () async {});
  });

  test('surfaces cleanup failures and keeps auth available for a retry',
      () async {
    final db = FakeFirebaseFirestore();
    await db.doc('custom_foods/u/items/f').set({'uid': 'u'});
    await db.doc('user_details/u').set({'uid': 'u'});
    var removeAuth = false;
    var failStorage = true;
    final service = AccountDeletionService(
        firestore: db,
        deleteFiles: (_) async {
          if (failStorage) throw StateError('synthetic storage outage');
        });
    Future<void> run() => service.deleteAccount(
        uid: 'u',
        deleteAuthUser: () async {
          removeAuth = true;
        });
    await expectLater(run(), throwsStateError);
    expect(removeAuth, isFalse);
    expect((await db.doc('user_details/u').get()).exists, isTrue);
    failStorage = false;
    await run();
    expect(removeAuth, isTrue);
    expect((await db.doc('custom_foods/u/items/f').get()).exists, isFalse);
  });

  test('a database failure is surfaced before files or auth removal', () async {
    final db = FakeFirebaseFirestore();
    await db.doc('calorie_logs/u/daily/day/meals/m').set({'uid': 'u'});
    db.securityRules = FakeFirebaseFirestore(securityRules: '''
      service cloud.firestore { match /databases/{database}/documents {
        match /{document=**} { allow read; allow write: if false; }
      }}''').securityRules;
    var filesDeleted = false;
    var authDeleted = false;
    final service = AccountDeletionService(
        firestore: db,
        deleteFiles: (_) async {
          filesDeleted = true;
        });
    await expectLater(
        service.deleteAccount(
            uid: 'u',
            deleteAuthUser: () async {
              authDeleted = true;
            }),
        throwsException);
    expect(filesDeleted, isFalse);
    expect(authDeleted, isFalse);
  });

  test('paginates nested cleanup beyond the batch limit', () async {
    final db = FakeFirebaseFirestore();
    for (var i = 0; i < 405; i++) {
      await db.doc('calorie_logs/u/daily/day/meals/m$i').set({'uid': 'u'});
    }
    await AccountDeletionService(firestore: db, deleteFiles: (_) async {})
        .deleteAccount(uid: 'u', deleteAuthUser: () async {});
    expect((await db.collectionGroup('meals').get()).docs, isEmpty);
  });

  test('recurses storage prefixes and surfaces failed deletions', () async {
    final deleted = <String>[];
    final nestedFile = _StorageRef('images/u/old/photo', deleted);
    final file = _StorageRef('images/u/profile', deleted);
    final nested = _StorageRef('images/u/old', deleted, items: [nestedFile]);
    final root =
        _StorageRef('images/u', deleted, items: [file], prefixes: [nested]);
    await deleteStorageTree(root);
    expect(deleted, ['images/u/old/photo', 'images/u/profile']);
    file.error =
        FirebaseException(plugin: 'firebase_storage', code: 'unauthorized');
    await expectLater(
        deleteStorageTree(root), throwsA(isA<FirebaseException>()));
  });
}

class _StorageRef implements Reference {
  _StorageRef(this.fullPath, this.deleted,
      {this.items = const [], this.prefixes = const []});
  @override
  final String fullPath;
  final List<String> deleted;
  final List<Reference> items;
  final List<Reference> prefixes;
  FirebaseException? error;
  @override
  Future<ListResult> listAll() async => _StorageListing(items, prefixes);
  @override
  Future<void> delete() async {
    if (error != null) throw error!;
    deleted.add(fullPath);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StorageListing implements ListResult {
  _StorageListing(this.items, this.prefixes);
  @override
  final List<Reference> items;
  @override
  final List<Reference> prefixes;
  @override
  String? get nextPageToken => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
