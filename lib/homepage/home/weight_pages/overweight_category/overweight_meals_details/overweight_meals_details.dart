import 'package:flutter/material.dart';
import 'package:nutri_tracker/homepage/home/weight_pages_model/meal%20model/weight_loss_meal.dart';

class overweight_meals_details extends StatefulWidget {
  const overweight_meals_details({Key? key}) : super(key: key);

  @override
  State<overweight_meals_details> createState() =>
      _overweight_meals_detailsState();
}

class _overweight_meals_detailsState extends State<overweight_meals_details> {
  final Wlossmeals wlossmealss = Wlossmeal[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wlossmeal[index].name'),
      ),
      // body: Center(
      //   child: Text(wlossmealss[index].name),
      // )
      // Center(child: Image.network(Wlossmeal.,),
    );
  }
}
