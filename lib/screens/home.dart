// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:nutri_tracker/drawer/drawermenu.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nutri_tracker/screens/detail.dart';
import 'package:nutri_tracker/screens/foodmodel.dart';
import 'package:nutri_tracker/screens/themes.dart';

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
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.watch_later_outlined),
                                          Text(
                                            '${foodlist[index].time} Min',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
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
                    );
                  }),
            ),
          ),
          // Section for additional logos
          // ListView(
          //   padding: EdgeInsets.only(left: 20.0, right: 20.0),
          //   scrollDirection: Axis.vertical,
          //   children: [
          //     SizedBox(
          //       height: 300,
          //       child: Padding(
          //         padding: const EdgeInsets.only(left: 8),
          //       ),
          //     ),
          //     // Food Detail Page
          //     Container(
          //       margin: EdgeInsets.only(left: 50, bottom: 400, top: 100),
          //       height: 250,
          //       child: ListView.builder(
          //           scrollDirection: Axis.horizontal,
          //           itemCount: foodlist.length,
          //           itemBuilder: (context, index) {
          //             return InkWell(
          //                 onTap: () => Navigator.push(
          //                     context,
          //                     MaterialPageRoute(
          //                         builder: (context) =>
          //                             foodDetail(foodModel: foodlist[index]))),
          //                 child: ClipRRect(
          //                   borderRadius: BorderRadius.all(Radius.circular(30)),
          //                   child: Container(
          //                     // width: 250,
          //                     child: Card(
          //                       child: Wrap(
          //                         children: [
          //                           Column(
          //                             children: [
          //                               Image.asset(
          //                                 foodlist[index].foodImage,
          //                                 height: 100,
          //                                 width: 200,
          //                                 fit: BoxFit.cover,
          //                               ),
          //                               SizedBox(
          //                                 height: 20,
          //                               ),
          //                               Row(
          //                                 children: [
          //                                   Text(
          //                                     foodlist[index].name,
          //                                     style: const TextStyle(
          //                                         fontSize: 16,
          //                                         fontWeight: FontWeight.bold),
          //                                   ),
          //                                   SizedBox(
          //                                     width: 20,
          //                                   ),
          //                                   Row(
          //                                     children: [
          //                                       Icon(
          //                                           Icons.watch_later_outlined),
          //                                       Text(
          //                                         '${foodlist[index].time} Min',
          //                                         style: const TextStyle(
          //                                             fontSize: 16,
          //                                             fontWeight:
          //                                                 FontWeight.bold),
          //                                       ),
          //                                     ],
          //                                   )
          //                                 ],
          //                               )
          //                             ],
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                   ),
          //                 ));
          //           }),
          //     ),
          //   ],
          // )
        ],
      ),
    );
  }
}
