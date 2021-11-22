import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/login_screens/login_page.dart';
import 'package:nutri_tracker/login_screens/user_model.dart';
import 'package:nutri_tracker/navigation.dart';
import 'package:nutri_tracker/onbparding_components/Onboarding.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screens/google_signin/google_signin.dart';

String? finalEmail;
String? Gmail;

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    checkGoogleUser();
    getValidationData().whenComplete(() async {
      Timer(
          Duration(milliseconds: 6000),
          () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      finalEmail == null ? Onboarding() : navPage())));
    });
    // _navigateToHome();
  }

  void checkGoogleUser() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final user = await auth.currentUser;
    if (user != null) {
      // UserModel.fromMap("user_details").email = await LocalDataSaver

    }
  }

  Future getValidationData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var obtainedEmail = sharedPreferences.getString('email');

    setState(() {
      finalEmail = obtainedEmail;
    });
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 6500), () {});
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Onboarding()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset('assets/images/op.gif'),
        ]),
      ),
    );
  }
}
