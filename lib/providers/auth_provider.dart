import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_tracker/database/user_model.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final currentUserModelProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  final firestore = ref.watch(firestoreProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return firestore
          .collection('user_details')
          .doc(user.uid)
          .snapshots()
          .map((doc) => UserModel.fromMap(doc.data()));
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});
