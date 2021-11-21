// ignore_for_file: prefer_const_constructors

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:nutri_tracker/drawer/drawermenu.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:nutri_tracker/screens/themes.dart';
import 'screens/diet.dart';
import 'screens/home.dart';
import 'screens/recipe.dart';

class navPage extends StatefulWidget {
  const navPage({Key? key}) : super(key: key);

  @override
  _navPageState createState() => _navPageState();
}

class _navPageState extends State<navPage> {
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
