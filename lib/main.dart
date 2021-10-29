import 'package:flutter/material.dart';
import 'package:nutri_tracker/splash.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Animation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // define our text field style
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white70,
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.black),
          contentPadding:
              EdgeInsets.symmetric(vertical: 16 * 1.2, horizontal: 16),
        ),
      ),
      home: const Splash(),
    );
  }
}
