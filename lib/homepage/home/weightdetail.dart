// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:nutri_tracker/homepage/home/weightdetailmodel.dart';
import 'package:nutri_tracker/themes.dart';

class foodDetail extends StatelessWidget {
  final FoodModel foodModel;
  const foodDetail({Key? key, required this.foodModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              foodModel.foodImage,
              width: 500,
              height: 200,
              fit: BoxFit.cover,
            ),
            title: Text(
              foodModel.name,
              style: TextStyle(
                  color: MyColors.heading,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            mainAxisExtent: 300,
          ),
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
            return Container(
              height: 100,
              width: 100,
              color: Colors.amber,
            );
          }, childCount: 10),
        ),
      ]),
    );
  }
}
 
      // Column(
      //   children: [
      //     SizedBox(
      //       height: 50,
      //     ),
      //     Container(
      //       margin: const EdgeInsets.only(right: 200),
      //       child: ClipRRect(
      //         borderRadius:
      //             const BorderRadius.only(bottomRight: Radius.circular(120)),
      //         child: Image.asset(
      //           foodModel.foodImage,
      //           width: 500,
      //           height: 200,
      //           fit: BoxFit.fill,
      //         ),
      //       ),
      //     ),
      //     CustomScrollView(
      //       slivers: [
      //         SliverAppBar(
      //           title: Text("dataaa"),
      //           backgroundColor: Colors.amber,
      //           expandedHeight: 350.0,
      //           flexibleSpace: FlexibleSpaceBar(
      //             title: Text("data"),
      //           ),
      //         ),
      //       ],
      //     ),
      //     Text("data"),
      //   ],
      // ),
  