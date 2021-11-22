import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nutri_tracker/login_screens/login_page.dart';
import 'package:nutri_tracker/navigation.dart';
import 'package:nutri_tracker/onbparding_components/Onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? finalEmail;

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
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
