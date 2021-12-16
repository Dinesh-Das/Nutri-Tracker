// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:nutri_tracker/homepage/home/weight_pages_model/meal%20model/weight_loss_meal.dart';

class overweight_meals_details extends StatefulWidget {
  final int index;
  const overweight_meals_details(
    this.index, {
    Key? key,
  }) : super(key: key);

  @override
  State<overweight_meals_details> createState() =>
      _overweight_meals_detailsState(index);
}

class _overweight_meals_detailsState extends State<overweight_meals_details> {
  final Wlossmeals wlossmealss = Wlossmeal[0];
  final int currentItem;
  _overweight_meals_detailsState(this.currentItem);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Wlossmeal[currentItem].name),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 250,
              width: 392,
              child: Image.network(
                Wlossmeal[currentItem].image,
                fit: BoxFit.cover,
              ),
            ),
            Divider(
              thickness: 2,
              endIndent: 30,
              indent: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 20),
              child: Container(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Wlossmeal[currentItem].name,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 20),
              child: Container(
                child: Text(
                  Wlossmeal[currentItem].ingredients,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            Divider(
              thickness: 2,
              endIndent: 30,
              indent: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Container(
                margin: EdgeInsets.only(right: 180),
                child: Text(
                  Wlossmeal[currentItem].nfacts,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            Divider(
              thickness: 2,
              endIndent: 30,
              indent: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 20),
              child: Container(
                child: Text(
                  Wlossmeal[currentItem].recipe,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
