import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/bottom_navigation.dart';
import 'package:nutri_tracker/database/user_model.dart';
import 'package:nutri_tracker/dialog.dart';
import 'package:nutri_tracker/screens/home/home.dart';

updateDetailsToFirestore(
    String? photoURL,
    String? username,
    String? name,
    String? phoneno,
    String? location,
    String? birthdate,
    String? bio,
    String? height,
    String? weight,
    String? gender,
    BuildContext context) async {
  // calling firestore
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  UserModel userModel = UserModel();

  userModel.uid = user!.uid;
  userModel.photoURL = photoURL;
  userModel.email = user.email;
  userModel.name = name;
  userModel.mobile = phoneno;
  userModel.username = username;
  userModel.location = location;
  userModel.birthdate = birthdate;
  userModel.bio = bio;
  userModel.height = height;
  userModel.weight = weight;
  userModel.gender = gender;

  showLoadingAlertDialog(context, 'Saving');
  await firebaseFirestore
      .collection("user_details")
      .doc(user.uid)
      .update(userModel.toMap());

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Data updated Successfully'),
    ),
  );

  Navigator.pushAndRemoveUntil(
      (context),
      MaterialPageRoute(builder: (context) => const BottomNavigation()),
      (route) => false);
}
