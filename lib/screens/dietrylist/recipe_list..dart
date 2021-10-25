// ignore_for_file: prefer_const_constructors, file_names

import 'package:flutter/material.dart';

class recipelist extends StatelessWidget {
  const recipelist({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView(
          children: [
            // ignore: prefer_const_constructors
            Padding(
              padding: const EdgeInsets.all(16.0),
              // ignore: prefer_const_constructors
              child: Text(
                'Healthy Veg Recipe',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 35,
                    fontWeight: FontWeight.w900),
              ),
            ),
            Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  child: Container(
                    color: Colors.blueGrey.withOpacity(0.2),
                    height: 150,
                    width: 350,
                    child: const Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Eggs',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
