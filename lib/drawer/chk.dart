import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/constants.dart';
import 'package:nutri_tracker/database/updateData.dart';
import 'package:nutri_tracker/database/user_model.dart';
import 'package:nutri_tracker/sharedPreferences/LocalData.dart';
import 'package:nutri_tracker/sharedPreferences/SharedPreferences.dart';

class Chk extends StatefulWidget {
  const Chk({Key? key}) : super(key: key);

  @override
  _ChkState createState() => _ChkState();
}

class _ChkState extends State<Chk> {
  //Displaying data from database
  User? user = FirebaseAuth.instance.currentUser;
  UserModel userData = UserModel();
  String? name = '';
  String? email = '';
  String? urlImage = '';
  String? username = '';
  String? gender = '';
  String? mobile = '';
  String? bio = '';
  String? birthdate = '';

  @override
  void initState() {
    super.initState();
    updateDetailsToFirestore('DinuSir', 'Debu', '9156744441', 'Abad',
        'Kya kar lega bro', 'Tujhse na ho payega', '6inch', 'mota', context);
    FirebaseFirestore.instance
        .collection("user_details")
        .doc(user!.uid)
        .get()
        .then((value) {
      userData = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    name = userData.username ?? 'Full Name';
    email = userData.email ?? 'Email';
    urlImage = userData.photoURL ?? defaultProfileUrl;
    username = userData.username ?? 'UserName';
    gender = userData.gender ?? 'Gender';
    bio = userData.bio ?? 'Bio';
    birthdate = userData.birthdate ?? 'BirthDate';
    mobile = userData.mobile ?? 'Mobile';

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(name.toString()),
              Text(email.toString()),
              Text(urlImage.toString()),
              Text(bio.toString()),
              Text(birthdate.toString()),
              Text(username.toString()),
              Text(gender.toString()),
              Text(name.toString()),
            ],
          ),
        ],
      ),
    );
  }
}
