// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class drawermenu extends StatelessWidget {
  const drawermenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
          elevation: 10,
          child: ListView(
            children: [
              ListTile(
                leading: Icon(Icons.home),
                title: Text('A S H U T O S H'),
                trailing: Icon(Icons.share),
              )
            ],
          )),
    );
  }
}
