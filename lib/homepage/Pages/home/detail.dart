import 'package:flutter/material.dart';
import 'package:nutri_tracker/homepage/Pages/home/foodmodel.dart';

class foodDetail extends StatelessWidget {
  final FoodModel foodModel;
  const foodDetail({Key? key, required this.foodModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 50,
          ),
          Center(
              child: Image.asset(
            foodModel.foodImage,
            width: 500,
            height: 200,
          ))
        ],
      ),
    );
  }
}
