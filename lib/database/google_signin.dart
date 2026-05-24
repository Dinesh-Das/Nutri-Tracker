import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nutri_tracker/database/user_model.dart';
import 'package:nutri_tracker/sharedPreferences/shared_preferences.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;
  UserModel? userModel;

  GoogleSignInAccount get user => _user!;

  googleLogin() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      _user = googleUser;

      //Local Data Shared Preference
      UserLocalData.saveGLoginData(true);
      UserLocalData.saveGImg(_user?.photoUrl ?? '');
      UserLocalData.saveGMail(_user?.email ?? '');
      UserLocalData.saveGName(_user?.displayName ?? '');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      final result =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseUser = result.user;
      if (firebaseUser != null) {
        userModel = UserModel(
          name: firebaseUser.displayName ?? _user?.displayName,
          email: firebaseUser.email ?? _user?.email,
          uid: firebaseUser.uid,
          photoURL: firebaseUser.photoURL ?? _user?.photoUrl,
        );

        final ref = FirebaseFirestore.instance
            .collection('user_details')
            .doc(firebaseUser.uid);
        final doc = await ref.get();
        final data = userModel!.toMap();
        if (!doc.exists) data['isOnboardingDone'] = false;
        await ref.set(data, SetOptions(merge: true));
      }

      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  googleLogOut() async {
    UserLocalData.saveGLoginData(false);
    this._user = await googleSignIn.disconnect();
    userModel = null;
    notifyListeners();
  }
}
