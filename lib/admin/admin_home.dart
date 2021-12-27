import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutri_tracker/admin/add_data.dart';
import 'package:nutri_tracker/admin/test.dart';
import 'package:nutri_tracker/admin/viewdata.dart';
import 'package:nutri_tracker/dark_theme/custom_theme.dart';
import 'package:nutri_tracker/login_screens/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool theme = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin-Panel"),
        leading: IconButton(
            onPressed: () {
              currentTheme.toggleTheme();

              setState(() {
                theme = !theme;
              });
            },
            icon: Icon(
              theme ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 30,
            )),
        actions: [
          IconButton(
              onPressed: () async {
                final SharedPreferences sharedPreferences =
                    await SharedPreferences.getInstance();
                sharedPreferences.clear();
                sharedPreferences.remove('logintype');
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()));
              },
              icon: const Icon(Icons.logout)),
        ],
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset("assets/images/admin.png"),
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => AddData()));
                      },
                      child: Text("Add Data"),
                      style: ElevatedButton.styleFrom(
                          primary:
                              Theme.of(context).appBarTheme.foregroundColor),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text("Update Data"),
                      style: ElevatedButton.styleFrom(
                          primary:
                              Theme.of(context).appBarTheme.foregroundColor),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text("Delete Data"),
                      style: ElevatedButton.styleFrom(
                          primary:
                              Theme.of(context).appBarTheme.foregroundColor),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ViewData()));
                      },
                      child: Text("View Data"),
                      style: ElevatedButton.styleFrom(
                          primary:
                              Theme.of(context).appBarTheme.foregroundColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
/**
 * TextButton(onPressed: () {}, child: Text("Add Nutritional Data")),
            TextButton(
                onPressed: () {
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (context) => TestFirebase()));
                },
                child: Text("Update Data")),
            TextButton(
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => ViewData()));
                  // var db =
                  //     FirebaseFirestore.instance.collection("NutritionalData");
                  // Map<String, dynamic> ourData = {
                  //   "image": "image",
                  //   "name": "name",
                  //   "desc": "desc",
                  //   "nfact": "nfact",
                  //   "benefits": "benefits",
                  //   "side_effects": "side_effects"
                  // };
                  // List data = ['overweight', 'underweight', 'normal'];
                  // for (int i = 0; i < 3; i++) {
                  //   db
                  //       .doc(data[i])
                  //       .collection('fruits')
                  //       .add(ourData)
                  //       .then((value) => print('success'));
                  //   db
                  //       .doc(data[i])
                  //       .collection('drinks')
                  //       .add(ourData)
                  //       .then((value) => print('success'));
                  //   db
                  //       .doc(data[i])
                  //       .collection('meals')
                  //       .add(ourData)
                  //       .then((value) => print('success'));
                  // }
                },
                child: Text("View Data")),
 */