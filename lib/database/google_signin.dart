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

      this.userModel = UserModel(
        name: this._user!.displayName,
        email: this._user!.email,
        uid: this._user!.id,
        photoURL: this._user!.photoUrl,
      );

      //Local Data Shared Preference
      UserLocalData.saveGLoginData(true);
      UserLocalData.saveGImg(_user?.photoUrl);
      UserLocalData.saveGMail(_user?.email);
      UserLocalData.saveGName(_user?.displayName);

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      await FirebaseAuth.instance.signInWithCredential(credential);

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
