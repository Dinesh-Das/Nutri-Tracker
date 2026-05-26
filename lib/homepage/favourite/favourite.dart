import 'package:flutter/material.dart' hide NavigationDrawer;
import 'package:nutri_tracker/drawer/drawermenu.dart';

import '../../../themes.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  _FavouritePageState createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const NavigationDrawer(),
        appBar: AppBar(
          title: Text(
            'Favourites',
            style: TextStyle(color: MyColors.heading),
          ),
          centerTitle: true,
          foregroundColor: MyColors.shortDesc,
          backgroundColor: MyColors.backColor,
          elevation: 0,
        ),
        body: const Center(
          child: Text('Hi'),
        ));
  }
}
