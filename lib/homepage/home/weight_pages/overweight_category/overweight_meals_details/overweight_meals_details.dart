import 'package:flutter/material.dart';
import 'package:nutri_tracker/homepage/home/weight_pages_model/meal_model/weight_loss_meal.dart';
import 'package:nutri_tracker/widgets/cached_app_image.dart';

class overweight_meals_details extends StatefulWidget {
  final int index;
  const overweight_meals_details(
    this.index, {
    super.key,
  });

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
            SizedBox(
              height: 250,
              width: 392,
              child: CachedAppImage(
                imageUrl: Wlossmeal[currentItem].image,
                fit: BoxFit.cover,
              ),
            ),
            const Divider(
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
            const Divider(
              thickness: 2,
              endIndent: 30,
              indent: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Container(
                margin: const EdgeInsets.only(right: 180),
                child: Text(
                  Wlossmeal[currentItem].nfacts,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const Divider(
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
