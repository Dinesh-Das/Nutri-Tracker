import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/custom_dialog.dart';
import '../homepage/bottom_navigation.dart';

Future<void> updateDetailsToFirestore(
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
    double? bmi,
    double? bmr,
    BuildContext context) async {
  // calling firestore
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  final data = <String, dynamic>{
    'uid': user!.uid,
    'photoURL': photoURL,
    'email': user.email,
    'name': name,
    'mobile': phoneno,
    'username': username,
    'location': location,
    'birthdate': birthdate,
    'bio': bio,
    'height': height,
    'weight': weight,
    'gender': gender,
    'bmi': bmi,
    'bmr': bmr,
  }..removeWhere((key, value) => value == null);

  showLoadingAlertDialog(context, 'Saving Data');
  try {
    await firebaseFirestore
        .collection("user_details")
        .doc(user.uid)
        .set(data, SetOptions(merge: true));
  } catch (error) {
    if (!context.mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unable to save profile: $error')),
    );
    return;
  }

  if (!context.mounted) return;
  Navigator.pop(context);
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

Future<void> updateProfilePicToFirestore(String? photoURL) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  await user.updatePhotoURL(photoURL);
  await FirebaseFirestore.instance
      .collection("user_details")
      .doc(user.uid)
      .set({
    'uid': user.uid,
    'photoURL': photoURL,
  }, SetOptions(merge: true));
}

Future<void> updateBMIData(
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
      .set({
    'uid': user.uid,
    'height': height,
    'weight': weight,
    'bmi': double.tryParse(bmi ?? ''),
    'bmr': double.tryParse(bmr ?? ''),
    'gender': gender,
    'lastBmiDate': Timestamp.now(),
  }, SetOptions(merge: true));

  await FirebaseFirestore.instance
      .collection('weight_logs')
      .doc(user.uid)
      .collection('entries')
      .add({
    'weight': double.tryParse(weight ?? '0') ?? 0,
    'bmi': double.tryParse(bmi ?? '0') ?? 0,
    'date': Timestamp.now(),
    'note': '',
  });
}
