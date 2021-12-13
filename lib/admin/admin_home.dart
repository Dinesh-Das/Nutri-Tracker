import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/admin/add_data.dart';
import 'package:nutri_tracker/admin/test.dart';
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddData()));
                },
                child: Text("Add Weight Data")),
            TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => TestFirebase()));
                },
                child: Text("Update Data")),
            TextButton(
                onPressed: () {
                  var data = FirebaseFirestore.instance
                      .collection('devi')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('prasad')
                      .get();
                  print(data);
                },
                child: Text("View Data")),
          ],
        ),
      ),
    );
  }
}
