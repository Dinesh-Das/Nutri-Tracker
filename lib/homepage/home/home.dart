// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, avoid_unnecessary_containers
import "dart:math";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/bmi/screens/calculator_screen.dart';
import 'package:nutri_tracker/constants.dart';
import 'package:nutri_tracker/dark_theme/custom_theme.dart';
import 'package:nutri_tracker/database/user_model.dart';
import 'package:nutri_tracker/custom_dialog.dart';
import 'package:nutri_tracker/drawer/drawermenu.dart';
import 'package:nutri_tracker/drawer/profile/view_profile.dart';
import 'package:nutri_tracker/homepage/home/quotes.dart';
import 'package:nutri_tracker/homepage/home/weight_pages/normalweight_home.dart';
import 'package:nutri_tracker/homepage/home/weight_pages/overweight_home.dart';
import 'package:nutri_tracker/homepage/home/weight_pages/underweight_home.dart';
import 'package:nutri_tracker/homepage/home/weightdetailmodel.dart';
import 'package:nutri_tracker/themes.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class home extends StatefulWidget {
  home({Key? key}) : super(key: key);

  static List<String> foodName = [
    'Under Weight',
    'Normal Weight',
    'Over Weight'
  ];
  static List<String> foodImage = [
    'assets/images/underweight.jpg',
    'assets/images/normalweight.jpg',
    'assets/images/overweight.jpg'
  ];
  static List<String> time = ['44', '43', '42'];

  @override
  State<home> createState() => _homeState();
}

int current = Random().nextInt(mylist.length);

class _homeState extends State<home> {
  Quotes data = mylist[current];
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  bool theme = false;
  String greetings() {
    var hour = DateTime.now().hour;
    if (hour <= 12) {
      return 'Morning';
    } else if (hour > 12 && hour <= 16) {
      return 'Afternoon';
    } else if (hour > 16 && hour < 24) {
      return 'Evening';
    }
    return 'Day';
  }

  @override
  void initState() {
    super.initState();
    // setState(() {});
    FirebaseFirestore.instance
        .collection("user_details")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());

      setState(() {
        current = Random().nextInt(mylist.length);
      });
    });
  }

  final List<FoodModel> foodlist = List.generate(
    home.foodName.length,
    (index) => FoodModel(
        name: home.foodName[index],
        foodImage: home.foodImage[index],
        time: home.time[index]),
  );

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'N U T R I - P R O V I D E R',
          // style: TextStyle(color: MyColors.heading),
        ),
        centerTitle: true,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () {
                currentTheme.toggleTheme();

                setState(() {
                  theme = !theme;
                });
              },
              icon: Icon(
                theme ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                size: 30,
              ))
        ],
      ),
      // drawer
      drawer: NavigationDrawer(),
      // backgroundColor: const Color(0xFFE9E9E9),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: height * 0.38,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(40.0),
                          bottomLeft: Radius.circular(40.0)),
                      child: Container(
                        height: height * 0.38,
                        color: Theme.of(context).appBarTheme.backgroundColor,
                        padding: EdgeInsets.only(left: 16, right: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text.rich(
                                    TextSpan(
                                      text:
                                          "Hey, ${loggedInUser.name ?? 'User'}!\n",
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Good ${greetings()}',
                                          style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ViewProfile()));
                                  },
                                  child: Container(
                                    child: CircleAvatar(
                                      radius: 35,
                                      backgroundImage: loggedInUser.photoURL ==
                                                  '' ||
                                              loggedInUser.photoURL == null
                                          ? NetworkImage(defaultProfileUrl)
                                          : NetworkImage(
                                              loggedInUser.photoURL.toString()),
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 4,
                                        color:
                                            Theme.of(context).bottomAppBarColor,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                            spreadRadius: 2,
                                            blurRadius: 10,
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            offset: const Offset(0, 10)),
                                      ],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 0,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircularPercentIndicator(
                                  radius: 140,
                                  backgroundColor:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  progressColor:
                                      Theme.of(context).iconTheme.color,
                                  percent: 0.4,
                                  lineWidth: 10,
                                  circularStrokeCap: CircularStrokeCap.round,
                                  animation: true,
                                  animationDuration: 2000,
                                  center: Text(
                                    "${loggedInUser.bmi ?? "BMI"}",
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    LimitedBox(
                                      maxWidth: 175,
                                      child: Text(
                                        data.quote.toString(),
                                        textDirection: TextDirection.ltr,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Raleway',
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      '- ${data.auther.toString()}',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontFamily: 'Raleway',
                                          fontWeight: FontWeight.bold),
                                      textDirection: TextDirection.ltr,
                                      textAlign: TextAlign.left,
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // underweight
                    Positioned(
                      top: height * 0.42,
                      left: 30,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          child: Container(
                            color:
                                Theme.of(context).appBarTheme.backgroundColor,
                            height: 220,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => underweightHome(),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                                child: Container(
                                  height: 220,
                                  width: 200,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(30),
                                    ),
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          'assets/weight/underweight.png',
                                          height: height * 0.20,
                                          width: 200,
                                          fit: BoxFit.cover,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        const Text('Under Weight',
                                            style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold))
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // normalweight
                    Positioned(
                      top: height * 0.42,
                      left: 30,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          child: Container(
                            color:
                                Theme.of(context).appBarTheme.backgroundColor,
                            height: 220,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => normalweightHome(),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                                child: Container(
                                  height: 220,
                                  width: 200,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(30),
                                    ),
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          'assets/weight/normalweight.png',
                                          height: height * 0.20,
                                          width: 200,
                                          fit: BoxFit.cover,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        const Text('Normal Weight',
                                            style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold))
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Over Weight
                    Positioned(
                      top: height * 0.42,
                      left: 30,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          child: Container(
                            color:
                                Theme.of(context).appBarTheme.backgroundColor,
                            height: 220,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => overweightHome(),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                                child: Container(
                                  height: 220,
                                  width: 200,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(30),
                                    ),
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          'assets/weight/overweight.png',
                                          height: height * 0.20,
                                          width: 200,
                                          fit: BoxFit.cover,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        const Text('Over Weight ',
                                            style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold))
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              SizedBox(
                height: 5,
              ),
              // calculate bmi
              Positioned(
                top: height * 0.42,
                left: 30,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    child: Container(
                        color: Theme.of(context).appBarTheme.backgroundColor,
                        height: 97,
                        child: InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CalculatorScreen())),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.calculate, size: 35),
                                Text(
                                  "Click here to calculate bmi",
                                  style: const TextStyle(fontSize: 22.0),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Positioned(
                top: height * 0.42,
                left: 30,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    child: Container(
                        color: Theme.of(context).appBarTheme.backgroundColor,
                        height: 300,
                        child: InkWell(
                          onTap: () {},
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            child: Center(
                              child: Text("Show Some Progress here"),
                            ),
                          ),
                        )),
                  ),
                ),
              ),
              SizedBox(
                height: height * 0.08,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
