// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:nutri_tracker/drawer/drawermenu.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nutri_tracker/screens/detail.dart';
import 'package:nutri_tracker/screens/foodmodel.dart';
import 'package:nutri_tracker/screens/themes.dart';
import 'package:nutri_tracker/sharedPreferences/constant.dart';
import 'package:nutri_tracker/sharedPreferences/shared.dart';

class home extends StatelessWidget {
  home({Key? key}) : super(key: key);

  static List<String> foodName = ['Breakfast', 'lunch', 'dinner'];
  static List<String> foodImage = [
    'assets/images/fruits.jpg',
    'assets/images/lunch.jpg',
    'assets/images/dinner.jpg'
  ];
  static List<String> time = ['44', '43', '42'];
  final List<FoodModel> foodlist = List.generate(
      foodName.length,
      (index) => FoodModel(
          name: foodName[index],
          foodImage: foodImage[index],
          time: time[index]));

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
          ClipRRect(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(40.0),
                bottomLeft: Radius.circular(40.0)),
            child: Container(
              height: 300,
              color: MyColors.backColor,
            ),
          ),

          // Section for additional logos
          ListView(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            scrollDirection: Axis.vertical,
            children: [
              SizedBox(
                height: 320,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                ),
              ),
              // Container(
              //   padding: EdgeInsets.only(left: 20.0),
              //   child: Text(
              //     'Favourite Buttons',
              //     style: TextStyle(
              //         fontFamily: 'lato',
              //         fontSize: 28.0,
              //         fontWeight: FontWeight.w800,
              //         color: MyColors.heading),
              //   ),
              // ),
              // Container(
              //   height: 200,
              //   padding: EdgeInsets.all(5),
              //   child: ClipRRect(
              //     borderRadius: BorderRadius.all(Radius.circular(40.0)),
              //     child: Container(
              //       // padding: EdgeInsets.all(20.0),
              //       color: Colors.deepPurpleAccent.withOpacity(0.3),
              //       height: 250,
              //       width: 50,
              //       child: Column(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           Padding(
              //             padding: const EdgeInsets.only(left: 60.0),
              //             child: Row(
              //               children: [
              //                 IconButton(
              //                   onPressed: () {},
              //                   icon: FaIcon(FontAwesomeIcons.hotdog),
              //                   splashColor: Colors.greenAccent[900],
              //                   iconSize: 40,
              //                 ),
              //                 SizedBox(width: 20.0),
              //                 IconButton(
              //                   onPressed: () {},
              //                   icon: Icon(
              //                     Icons.local_pizza_outlined,
              //                   ),
              //                   splashColor: Colors.greenAccent[900],
              //                   iconSize: 40,
              //                 ),
              //                 SizedBox(width: 20.0),
              //                 IconButton(
              //                   onPressed: () {},
              //                   icon: FaIcon(FontAwesomeIcons.amazonPay),
              //                   splashColor: Colors.greenAccent[900],
              //                   iconSize: 40,
              //                 ),
              //               ],
              //             ),
              //           ),
              //           Padding(
              //             padding: const EdgeInsets.only(left: 60.0, top: 20.0),
              //             child: Row(
              //               children: [
              //                 IconButton(
              //                   onPressed: () {},
              //                   icon: FaIcon(FontAwesomeIcons.paypal),
              //                   splashColor: Colors.greenAccent[900],
              //                   iconSize: 40,
              //                 ),
              //                 SizedBox(width: 20.0),
              //                 IconButton(
              //                   onPressed: () {},
              //                   icon: FaIcon(FontAwesomeIcons.ccPaypal),
              //                   splashColor: Colors.greenAccent[900],
              //                   iconSize: 40,
              //                 ),
              //                 SizedBox(width: 20.0),
              //                 IconButton(
              //                   onPressed: () {},
              //                   icon: FaIcon(FontAwesomeIcons.googlePay),
              //                   splashColor: Colors.greenAccent[900],
              //                   iconSize: 40,
              //                 ),
              //               ],
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),

              // Food Detail Page
              Container(
                margin: EdgeInsets.only(left: 50, bottom: 400, top: 100),
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
                            child: Container(
                              // width: 250,
                              child: Card(
                                child: Wrap(
                                  children: [
                                    Column(
                                      children: [
                                        Image.asset(
                                          foodlist[index].foodImage,
                                          height: 100,
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
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                    Icons.watch_later_outlined),
                                                Text(
                                                  '${foodlist[index].time} Min',
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ));
                    }),
              ),
            ],
          )
        ],
      ),
    );
  }
}
