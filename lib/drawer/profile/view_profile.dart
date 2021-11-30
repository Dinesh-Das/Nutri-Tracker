import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/constants.dart';
import 'package:nutri_tracker/database/user_model.dart';
import 'package:nutri_tracker/dialog.dart';
import 'package:nutri_tracker/drawer/settings/settings.dart';
import 'package:intl/intl.dart';

class ViewProfile extends StatefulWidget {
  const ViewProfile({Key? key}) : super(key: key);

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  // String name = userData!.name.toString();
  UserModel retrivedData = UserModel();
  User? user = FirebaseAuth.instance.currentUser;
  DateFormat? formatter = DateFormat('yyyy-MM-dd');
  DateTime? creationDate;
  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection("user_details")
        .doc(user!.uid)
        .get()
        .then((value) {
      retrivedData = UserModel.fromMap(value.data());
      creationDate = user!.metadata.creationTime;
      retrivedData.creation = formatter!.format(creationDate!);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 250,
              child: Stack(
                children: [
                  ClipPath(
                    clipper: MyCustomClipper(),
                    child: Container(
                      height: 250,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(defaultProfileViewingUrl),
                        ),
                      ),
                    ),
                  ),
                  // User PRofile
                  Align(
                    alignment: const Alignment(0, 1),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          // child: ClipRRect(
                          //   borderRadius: BorderRadius.circular(80.0),
                          //   child: (retrivedData.photoURL == "")
                          //       ? Image.network(
                          //           defaultProfileUrl,
                          //           fit: BoxFit.cover,
                          //           width: 120,
                          //           height: 120,
                          //         )
                          //       : Image.network(
                          //           retrivedData.photoURL.toString(),
                          //           fit: BoxFit.cover,
                          //           width: 120,
                          //           height: 120,
                          //         ),
                          // ),
                          child: CircleAvatar(
                            backgroundImage: (retrivedData.photoURL == "")
                                ? NetworkImage(defaultProfileUrl)
                                : NetworkImage(
                                    retrivedData.photoURL.toString()),
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(width: 4, color: Colors.white),
                            boxShadow: [
                              BoxShadow(
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  color: Colors.black.withOpacity(0.1),
                                  offset: const Offset(0, 10)),
                            ],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          retrivedData.username.toString(),
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          retrivedData.email.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  //Appbar
                  SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back_ios_new),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SettingsPage()));
                          },
                          icon: const Icon(Icons.settings),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            displayData(Icons.face_retouching_natural_sharp,
                retrivedData.name.toString(), retrivedData.gender.toString()),
            displayData(Icons.mobile_screen_share_outlined,
                retrivedData.mobile.toString(), "Verified"),
            displayData(Icons.local_hospital_outlined, "Date of Birth",
                retrivedData.birthdate.toString()),
            displayData(Icons.height, "Height", retrivedData.height.toString()),
            displayData(Icons.monitor_weight_outlined, "Weight",
                retrivedData.weight.toString()),
            displayData(Icons.location_on_outlined, "Place",
                retrivedData.location.toString()),
            displayData(Icons.timelapse, "Joined Date",
                retrivedData.creation.toString()),
            displayData(
                Icons.health_and_safety_outlined, "BMI : 22", "BMR : somthing"),
            displayData(Icons.code, "About", retrivedData.bio.toString()),
            const SizedBox(
              height: 25,
            ),
          ],
        ),
      ),
    );
  }

  Padding displayData(IconData iconData, String title, String data) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              iconData,
              size: 40,
              color: Colors.blue,
            ),
            const SizedBox(
              width: 25,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  data,
                  style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
                )
              ],
            ),
          ],
        ),
      )),
    );
  }
}
//GoogleFonts.openSans().fontfamily

class MyCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 150);
    path.lineTo(0, size.height);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
