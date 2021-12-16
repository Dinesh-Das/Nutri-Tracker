// ignore_for_file: prefer_const_constructors, avoid_print

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nutri_tracker/homepage/home/home.dart';
import 'package:nutri_tracker/homepage/home/weight_pages/overweight_category/overweight_meals_details/overweight_meals_details.dart';
import 'package:nutri_tracker/homepage/home/weight_pages_model/meal%20model/weight_loss_meal.dart';
import 'package:nutri_tracker/homepage/home/weight_pages_model/weight_gain_frt_model.dart';

class overweightmeals extends StatefulWidget {
  const overweightmeals({Key? key}) : super(key: key);

  @override
  _overweightmealsState createState() => _overweightmealsState();
}

// int current = Random().nextInt(WLFruitsList.length);

class _overweightmealsState extends State<overweightmeals> {
  // Wgainfruits wgainfruit = WGFruitsList[0];
  Wlossmeals wlossmeals = Wlossmeal[0];

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          backgroundColor: Colors.white,
          expandedHeight: 500,
          stretch: true,
          pinned: true,
          // floating: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Image.asset(
              'assets/weight/underweight.png',
              width: 500,
              height: 200,
              fit: BoxFit.cover,
            ),
            title: const Text(
              'Weight Gain Fruits & Drinks',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            mainAxisExtent: 300,
          ),
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => overweight_meals_details(index),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(30),
                  ),
                  child: Container(
                    color: Colors.black12,
                    height: 220,
                    width: 200,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(30),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: NetworkImage(
                              Wlossmeal[index].image,
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Transform.translate(
                          offset: Offset(50, -90),
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 60, vertical: 110),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white),
                            child: IconButton(
                              onPressed: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => home(),
                                //   ),
                                // );
                                print('Added to Fav.');
                              },
                              icon: Icon(
                                Icons.favorite_outlined,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    //  Column(
                    //   children: [
                    //     Image.network(
                    //       Wlossmeal[index].image,
                    //       height: height * 0.20,
                    //       width: 200,
                    //       fit: BoxFit.cover,
                    //     ),
                    //     SizedBox(
                    //       height: 20,
                    //     ),
                    //     // SizedBox(
                    //     //   height: 60,
                    //     //   child: Transform.translate(
                    //     //     offset: Offset(50, -150),
                    //     //     child: Container(
                    //     //       margin: EdgeInsets.symmetric(
                    //     //           horizontal: 40, vertical: 10),
                    //     //       decoration: BoxDecoration(
                    //     //           borderRadius: BorderRadius.circular(10),
                    //     //           color: Colors.white),
                    //     //       child: IconButton(
                    //     //           onPressed: () {
                    //     //             Navigator.push(
                    //     //               context,
                    //     //               MaterialPageRoute(
                    //     //                 builder: (context) => home(),
                    //     //               ),
                    //     //             );
                    //     //           },
                    //     //           icon: Icon(Icons.bookmark_add_outlined)),
                    //     //     ),
                    //     //   ),
                    //     // ),
                    //     Padding(
                    //       padding:
                    //           const EdgeInsets.only(left: 8.0, right: 7.0),
                    //       child: Text(
                    //         Wlossmeal[index].name,
                    //         style: TextStyle(
                    //             fontSize: 18, fontWeight: FontWeight.bold),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ),
                ),
              ),
            );
          }, childCount: Wlossmeal.length),
        ),
      ]),
    );
  }
}
