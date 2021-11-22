// ignore_for_file: unnecessary_this

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nutri_tracker/login_screens/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          photoURL: this._user!.photoUrl);

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      await FirebaseAuth.instance.signInWithCredential(credential);

      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var gmail = googleAuth.idToken.toString();
      sharedPreferences.setString('gmail', gmail);
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  googleLogOut() async {
    this._user = await googleSignIn.disconnect();
    userModel = null;
    notifyListeners();
  }
}
