import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/drawer/profile/view_profile.dart';
import 'package:nutri_tracker/drawer/settings/settings.dart';
import 'package:nutri_tracker/homepage/Pages/dietrylist/diet.dart';
import 'package:nutri_tracker/homepage/Pages/favourite/favourite.dart';
import 'package:nutri_tracker/homepage/Pages/home/home.dart';
import 'package:nutri_tracker/themes.dart';

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
    const diet(),
    // const ViewProfile(),
  ];
  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      const Icon(
        Icons.favorite_border,
        size: 30,
      ),
      const Icon(
        Icons.home_outlined,
        size: 30,
      ),
      Icon(
        Icons.search_outlined,
        size: 30,
      ),
      // Icon(
      //   Icons.person,
      //   size: 30,
      // )
    ];
    return Scaffold(
      extendBody: true,
      body: screens[index],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
            // iconTheme: IconThemeData(color: Colors.white),
            ),
        child: CurvedNavigationBar(
          key: navigationKey,
          color: MyColors.bottomNav,
          buttonBackgroundColor: MyColors.iconsColor,
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
      ),
    );
  }
}

// ontap to change state of curved nav
// final navigationState = navigationState.currentState;
// navigationState.setPage(0);