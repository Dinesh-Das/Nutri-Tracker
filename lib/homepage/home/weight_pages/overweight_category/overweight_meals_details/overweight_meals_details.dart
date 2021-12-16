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
        ),
        body: Center(
          child: Text(Wlossmeal[currentItem].recipe),
        )
        // Center(child: Image.network(Wlossmeal.,),
        );
  }
}
