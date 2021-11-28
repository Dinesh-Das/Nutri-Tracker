import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/database/user_model.dart';

updateDetailsToFirestore(
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
  final CollectionReference collectionReference =
      firebaseFirestore.collection('user_details');
  User? user = FirebaseAuth.instance.currentUser;
  UserModel userModel = UserModel();

  userModel.uid = user!.uid;
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

  await firebaseFirestore
      .collection("user_details")
      .doc(user.uid)
      .update(userModel.toMap());

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Data updated Successfully'),
    ),
  );
  Navigator.pop(context);
  // Navigator.pushAndRemoveUntil(
  //     (context),
  //     MaterialPageRoute(builder: (context) => const navPage()),
  //     (route) => false);
}
