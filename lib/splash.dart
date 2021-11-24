import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/login_screens/login_page.dart';
import 'package:nutri_tracker/login_screens/user_model.dart';
import 'package:nutri_tracker/navigation.dart';
import 'package:nutri_tracker/onbparding_components/Onboarding.dart';
import 'package:nutri_tracker/sharedPreferences/constant.dart';
import 'package:nutri_tracker/sharedPreferences/shared.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screens/google_signin/google_signin.dart';

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
  }

  void checkGoogleUser() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final user = await auth.currentUser;
    if (user != null) {
      DataConstant.gname = (await UserLocalData.getGName());
      DataConstant.gmail = (await UserLocalData.getGEmail());
      DataConstant.gimg = (await UserLocalData.getGImg());
      DataConstant.name = (await UserLocalData.getName());
      DataConstant.mail = (await UserLocalData.getEmail());
      DataConstant.photo = (await UserLocalData.getImg());

      Timer(
          const Duration(milliseconds: 6000),
          () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => navPage())));
    } else {
      Timer(
          const Duration(milliseconds: 6000),
          () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Onboarding())));
    }
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
