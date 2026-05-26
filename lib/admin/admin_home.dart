import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/admin/add_data.dart';
import 'package:nutri_tracker/admin/indian_foods_admin.dart';
import 'package:nutri_tracker/admin/viewdata.dart';
import 'package:nutri_tracker/dark_theme/custom_theme.dart';
import 'package:nutri_tracker/login_screens/login_page.dart';
import 'package:nutri_tracker/services/firestore_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool theme = false;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: FirestoreService().isCurrentUserAdmin(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data != true) {
          return Scaffold(
            appBar: AppBar(title: const Text("Admin-Panel")),
            body: const Center(child: Text('Admin access required.')),
          );
        }
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AddData()));
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .appBarTheme
                                  .foregroundColor),
                          child: const Text("Add Data"),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .appBarTheme
                                  .foregroundColor),
                          child: const Text("Update Data"),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .appBarTheme
                                  .foregroundColor),
                          child: const Text("Delete Data"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ViewData()));
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .appBarTheme
                                  .foregroundColor),
                          child: const Text("View Data"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const IndianFoodsAdminScreen()));
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .appBarTheme
                                  .foregroundColor),
                          child: const Text("Indian Foods"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
