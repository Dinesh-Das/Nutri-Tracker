import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nutri_tracker/login_screens/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

showAlertDialog(BuildContext context) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: const Text("Cancel"),
    onPressed: () {
      Navigator.pop(context);
    },
  );
  Widget continueButton = TextButton(
    child: const Text("Continue"),
    onPressed: () async {
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      // sharedPreferences.clear(); for all data

      try {
        FirebaseAuth.instance.currentUser!.delete();
        GoogleSignIn().signOut();
        sharedPreferences.remove('email');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'The user must reauthenticate before this operation can be executed.'),
            ),
          );
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account Deleted Successfully!'),
        ),
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: const Text("Warning"),
    content: const Text("Are you sure you want to delete account?"),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
