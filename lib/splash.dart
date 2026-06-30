import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_tracker/routes/app_routes.dart';
import 'package:nutri_tracker/sharedPreferences/local_data.dart';
import 'package:nutri_tracker/sharedPreferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

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
    final user = auth.currentUser;
    if (user != null) {
      DataConstant.gname = (await UserLocalData.getGName());
      DataConstant.gmail = (await UserLocalData.getGEmail());
      DataConstant.gimg = (await UserLocalData.getGImg());
      DataConstant.name = (await UserLocalData.getName());
      DataConstant.mail = (await UserLocalData.getEmail());
      DataConstant.photo = (await UserLocalData.getImg());

      final doc = await FirebaseFirestore.instance
          .collection('user_details')
          .doc(user.uid)
          .get();
      final data = doc.data() ?? {};
      await Future<void>.delayed(const Duration(milliseconds: 6000));
      if (!mounted) return;
      if (data['isAdmin'] == true) {
        context.go(AppRoutes.admin);
      } else if (data['isOnboardingDone'] != true) {
        context.go(AppRoutes.onboarding);
      } else {
        context.go(AppRoutes.dashboard);
      }
    } else {
      Timer(const Duration(milliseconds: 6000), () {
        if (mounted) context.go(AppRoutes.login);
      });
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
