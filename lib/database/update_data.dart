import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/database/user_model.dart';
import 'package:nutri_tracker/custom_dialog.dart';
import '../homepage/bottom_navigation.dart';

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
    String? bmi,
    String? bmr,
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
  userModel.bmi = bmi;
  userModel.bmr = bmr;

  showLoadingAlertDialog(context, 'Saving Data');
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

updateProfilePicToFirestore(String? photoURL) async {
  // calling firestore

  User? user = FirebaseAuth.instance.currentUser;
  UserModel userModel = UserModel();

  userModel.uid = user!.uid;

  user.updatePhotoURL(photoURL).then((value) {
    FirebaseFirestore.instance
        .collection("user_details")
        .where('uid', isEqualTo: user.uid)
        .get()
        .then((value) {
      FirebaseFirestore.instance
          .doc("user_details/${value.docs[0].id}")
          .update({'photoURL': photoURL}).then(
              (value) => print('Updated Profile Picture'));
    }).catchError((e) {
      print(e.toString());
    });
  }).catchError((e) {
    print(e.toString());
  });
}

updateBMIData(
  String? height,
  String? weight,
  String? bmi,
  String? gender,
  String? bmr,
) async {
  User? user = FirebaseAuth.instance.currentUser;
  await FirebaseFirestore.instance
      .collection("user_details")
      .doc(user!.uid)
      .update({
    'height': height,
    'weight': weight,
    'bmi': bmi,
    'bmr': bmr,
    'gender': gender,
  });
}
