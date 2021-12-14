// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:nutri_tracker/homepage/home/weight_pages/overweight_category/overeight_drinks.dart';
import 'package:nutri_tracker/homepage/home/weight_pages/overweight_category/overweight_fruit.dart';
import 'package:nutri_tracker/homepage/home/weight_pages/overweight_category/overweight_meals.dart';

class overweightHome extends StatelessWidget {
  const overweightHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: Icon(Icons.inventory_outlined),
        title: Text('Overweight Categories',
            style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => overweightfruits(),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      height: 200,
                      width: 350,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.5),
                              BlendMode.multiply),
                          fit: BoxFit.cover,
                          image: NetworkImage(
                              "https://images.pexels.com/photos/1128678/pexels-photo-1128678.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940"),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Fruits',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => normalweight(),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      height: 200,
                      width: 350,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.5),
                              BlendMode.multiply),
                          fit: BoxFit.cover,
                          image: NetworkImage(
                              "https://images.pexels.com/photos/1149302/pexels-photo-1149302.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940"),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Drinks',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => overweightmeals(),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      height: 200,
                      width: 350,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.5),
                              BlendMode.multiply),
                          fit: BoxFit.cover,
                          image: NetworkImage(
                              "https://images.pexels.com/photos/6544381/pexels-photo-6544381.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500"),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Meals',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
