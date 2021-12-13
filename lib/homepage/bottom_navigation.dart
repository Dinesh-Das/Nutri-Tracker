import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/drawer/profile/view_profile.dart';
import 'package:nutri_tracker/drawer/settings/settings.dart';
import 'package:nutri_tracker/themes.dart';

import 'dietrylist/diet.dart';
import 'favourite/favourite.dart';
import 'home/home.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  final navigationKey = GlobalKey<CurvedNavigationBarState>();
  int index = 1;
  final screens = [
    const FavouritePage(),
    home(),
    // const diet(),
    const ViewProfile(),
  ];
  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      const Icon(
        Icons.favorite,
        size: 30,
      ),
      const Icon(
        Icons.home,
        size: 30,
      ),
      // Icon(
      //   Icons.search,
      //   size: 30,
      // ),
      // Icon(
      //   Icons.person,
      //   size: 30,
      // )
    ];
    return Scaffold(
      extendBody: true,
      body: screens[index],
      bottomNavigationBar: CurvedNavigationBar(
        key: navigationKey,
        color: Theme.of(context).backgroundColor,
        buttonBackgroundColor: Theme.of(context).bottomAppBarColor,
        backgroundColor: Colors.transparent,
        items: items,
        height: 50,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        index: index,
        onTap: (index) => setState(() {
          this.index = index;
        }),
      ),
    );
  }
}

// ontap to change state of curved nav
// final navigationState = navigationState.currentState;
// navigationState.setPage(0);