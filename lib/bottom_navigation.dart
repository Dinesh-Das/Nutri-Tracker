import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/screens/dietrylist/diet.dart';
import 'package:nutri_tracker/screens/home/home.dart';
import 'package:nutri_tracker/screens/themes.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;
  List listOfPages = [
    home(),
    const diet(),
    // recipe(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
          height: 50,
          buttonBackgroundColor: MyColors.iconsColor,
          backgroundColor: Colors.transparent,
          color: MyColors.backColor,
          animationDuration: Duration(milliseconds: 500),
          animationCurve: Curves.ease,
          index: _selectedIndex,
          // key: Key(value),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          // ignore: prefer_const_literals_to_create_immutables
          items: [
            Icon(
              Icons.home,
              size: 30,
            ),
            Icon(
              Icons.fitness_center_outlined,
              size: 30,
            ),
            // Icon(
            //   Icons.food_bank,
            //   size: 30,
            // )
          ]),
      body: listOfPages[_selectedIndex],
    );
  }
}
