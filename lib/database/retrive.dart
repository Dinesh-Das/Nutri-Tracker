import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/database/user_model.dart';

Future getDataFromFirestore() async {
  // calling firestore
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final CollectionReference collectionReference =
      firebaseFirestore.collection('user_details');
  User? user = FirebaseAuth.instance.currentUser;

  UserModel retrivedData = UserModel();

  retrivedData.uid = user!.uid;
  retrivedData.email = user.email;

  await firebaseFirestore
      .collection("user_details")
      .doc(user.uid)
      .get()
      .then((value) => retrivedData = UserModel.fromMap(value.data()));
}
