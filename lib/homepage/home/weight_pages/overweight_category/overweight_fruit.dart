import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nutri_tracker/homepage/home/weight_pages_model/weight_loss_frt_model.dart';

class overweightfruits extends StatefulWidget {
  const overweightfruits({Key? key}) : super(key: key);

  @override
  _overweightfruitsState createState() => _overweightfruitsState();
}

// int current = Random().nextInt(WLFruitsList.length);

class _overweightfruitsState extends State<overweightfruits> {
  Wlossfruits wlossfruit = WLFruitsList[0];

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
              'assets/weight/overweight.png',
              width: 500,
              height: 200,
              fit: BoxFit.cover,
            ),
            title: const Text(
              'Weight Loss Fruits & Drinks',
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
              child: Container(
                height: 220,
                width: 200,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(30),
                  ),
                  child: Column(
                    children: [
                      Image.network(
                        WLFruitsList[index].image,
                        height: height * 0.20,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        WLFruitsList[index].name,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }, childCount: WLFruitsList.length),
        ),
      ]),
    );
  }
}
