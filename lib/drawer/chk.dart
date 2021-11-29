import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/constants.dart';
import 'package:nutri_tracker/database/update_data.dart';
import 'package:nutri_tracker/database/user_model.dart';
import 'package:nutri_tracker/sharedPreferences/local_data.dart';
import 'package:nutri_tracker/sharedPreferences/shared_preferences.dart';

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
              const CircleAvatar(
                radius: 100,
                backgroundImage: NetworkImage(
                    "https://firebasestorage.googleapis.com/v0/b/nutri-tracker-34aef.appspot.com/o/images%2F539UKfZptbNpumdKjsFZQ0ZIEfi1?alt=media&token=fc4dd7b6-b277-4103-baba-742781ead5af"),
              ),
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
