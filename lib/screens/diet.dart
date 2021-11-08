import 'package:flutter/material.dart';
import 'package:nutri_tracker/screens/themes.dart';
import 'dietrylist/dietry_list.dart';
import 'themes.dart';

class diet extends StatelessWidget {
  const diet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Colors.amber,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: Icon(
            Icons.local_hospital,
            color: MyColors.iconsColor,
            size: 35.0,
          ),
          title: Text(
            'Diet',
            style: TextStyle(color: MyColors.subHeading, fontSize: 25),
          ),
        ),
        body: const dietrylist());
  }
}
