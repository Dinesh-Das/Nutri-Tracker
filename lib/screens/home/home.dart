// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, avoid_unnecessary_containers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/constants.dart';
import 'package:nutri_tracker/database/user_model.dart';
import 'package:nutri_tracker/drawer/drawermenu.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nutri_tracker/screens/home/detail.dart';
import 'package:nutri_tracker/screens/home/foodmodel.dart';
import 'package:nutri_tracker/screens/themes.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class home extends StatefulWidget {
  home({Key? key}) : super(key: key);

  static List<String> foodName = ['Breakfast', 'lunch', 'dinner'];
  static List<String> foodImage = [
    'assets/images/fruits.jpg',
    'assets/images/lunch.jpg',
    'assets/images/dinner.jpg'
  ];
  static List<String> time = ['44', '43', '42'];

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection("user_details")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  final List<FoodModel> foodlist = List.generate(
      home.foodName.length,
      (index) => FoodModel(
          name: home.foodName[index],
          foodImage: home.foodImage[index],
          time: home.time[index]));

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'N U T R I T R A C K E R',
          // style: TextStyle(color: MyColors.heading),
        ),
        centerTitle: true,
        foregroundColor: MyColors.shortDesc,
        backgroundColor: MyColors.backColor,
        elevation: 0,
      ),
      // drawer
      drawer: NavigationDrawer(),
      // backgroundColor: const Color(0xFFE9E9E9),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: height * 0.35,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(40.0),
                  bottomLeft: Radius.circular(40.0)),
              child: Container(
                height: 300,
                color: MyColors.backColor,
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text("Hey, ${loggedInUser.name ?? 'User'}!"),
                      subtitle: Text(
                        "Good Evening!",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      // trailing: ClipOval(
                      //   child: CircleAvatar(
                      //     backgroundImage: loggedInUser.photoURL == ''
                      //         ? NetworkImage(defaultProfileUrl)
                      //         : NetworkImage(
                      //             loggedInUser.photoURL.toString(),
                      //           ),
                      //   ),
                      // ),
                    ),
                    CircularPercentIndicator(
                      radius: 150,
                      backgroundColor: Colors.white,
                      progressColor: MyColors.iconsColor,
                      percent: 0.4,
                      lineWidth: 10,
                      circularStrokeCap: CircularStrokeCap.round,
                      animation: true,
                      animationDuration: 2000,
                      center: Text(
                        "0.4",
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: height * 0.40,
            left: 30,
            right: 0,
            child: Container(
              height: 250,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: foodlist.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  foodDetail(foodModel: foodlist[index]))),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        child: Card(
                          color: MyColors.iconsColor,
                          child: Wrap(
                            children: [
                              Column(
                                children: [
                                  Image.asset(
                                    foodlist[index].foodImage,
                                    height: height * 0.22,
                                    width: 200,
                                    fit: BoxFit.cover,
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        foodlist[index].name,
                                        style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
