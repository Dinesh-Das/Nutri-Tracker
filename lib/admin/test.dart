import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/database/user_model.dart';

class TestFirebase extends StatefulWidget {
  const TestFirebase({Key? key}) : super(key: key);

  @override
  _TestFirebaseState createState() => _TestFirebaseState();
}

User? user = FirebaseAuth.instance.currentUser;
UserModel updateData = UserModel();

class _TestFirebaseState extends State<TestFirebase> {
  @override
  void initState() {
    super.initState();
    updateData.name = 'PersonTest';
    FirebaseFirestore.instance
        .collection("person")
        .doc(user!.uid)
        .update(updateData.toMap());

    FirebaseFirestore.instance
        .collection("person")
        .doc(user!.uid)
        .get()
        .then((value) {
      updateData = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Text(updateData.name.toString()),
            Text(updateData.name.toString())
          ],
        ),
      ),
    );
  }
}
