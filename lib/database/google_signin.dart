import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nutri_tracker/database/user_model.dart';
import 'package:nutri_tracker/sharedPreferences/shared_preferences.dart';

final googleSignInProvider =
    AsyncNotifierProvider<GoogleSignInController, UserModel?>(
  GoogleSignInController.new,
);

class GoogleSignInController extends AsyncNotifier<UserModel?> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Future<UserModel?> build() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return null;
    final doc = await FirebaseFirestore.instance
        .collection('user_details')
        .doc(firebaseUser.uid)
        .get();
    return UserModel.fromMap(doc.data());
  }

  Future<void> googleLogin() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return state.valueOrNull;

      UserLocalData.saveGLoginData(true);
      UserLocalData.saveGImg(googleUser.photoUrl ?? '');
      UserLocalData.saveGMail(googleUser.email);
      UserLocalData.saveGName(googleUser.displayName ?? '');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseUser = result.user;
      if (firebaseUser == null) return null;

      final userModel = UserModel(
        name: firebaseUser.displayName ?? googleUser.displayName,
        email: firebaseUser.email ?? googleUser.email,
        uid: firebaseUser.uid,
        photoURL: firebaseUser.photoURL ?? googleUser.photoUrl,
      );

      final ref = FirebaseFirestore.instance
          .collection('user_details')
          .doc(firebaseUser.uid);
      final doc = await ref.get();
      final data = userModel.toMap();
      if (!doc.exists) data['isOnboardingDone'] = false;
      await ref.set(data, SetOptions(merge: true));
      return userModel;
    });
  }

  Future<void> googleLogOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      UserLocalData.saveGLoginData(false);
      await _googleSignIn.disconnect();
      await FirebaseAuth.instance.signOut();
      return null;
    });
  }
}
