import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';

import 'screens/diet.dart';
import 'screens/home.dart';
import 'screens/recipe.dart';

class homepage extends StatefulWidget {
  const homepage({Key? key}) : super(key: key);

  @override
  _homepageState createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  int _selectedIndex = 0;
  // List listOfPages = [
  //   Container(
  //     color: Color(Colors.accents),
  //   )
  // ];

  List listOfPages = [
    const home(),
    const diet(),
    const recipe(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: listOfPages[_selectedIndex],
        bottomNavigationBar: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40.0)),
          child: BottomNavyBar(
            selectedIndex: _selectedIndex,
            showElevation: true, // use this to remove appBar's elevation
            onItemSelected: (index) => setState(() {
              _selectedIndex = index;
            }),
            backgroundColor: Colors.transparent,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            curve: Curves.slowMiddle,
            items: [
              BottomNavyBarItem(
                  icon: Icon(Icons.house),
                  title: Text('Home'),
                  activeColor: Colors.red,
                  textAlign: TextAlign.center),
              BottomNavyBarItem(
                  icon: Icon(Icons.health_and_safety),
                  title: Text('Dietry'),
                  activeColor: Colors.purpleAccent,
                  textAlign: TextAlign.center),
              BottomNavyBarItem(
                  icon: Icon(Icons.food_bank_sharp),
                  title: Text('Recipe'),
                  activeColor: Colors.pink,
                  textAlign: TextAlign.center),
            ],
          ),
        ));
  }
}
