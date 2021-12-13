// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:nutri_tracker/homepage/Pages/home/weight_pages/next%20page/overweight.dart';

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
        title: Text('Categories', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => overweight(),
                  ),
                );
              },
              child: ListTile(
                leading: Icon(
                  Icons.local_drink_outlined,
                  size: 25,
                ),
                title: Text(
                  'Fruits',
                  style: TextStyle(fontSize: 25),
                ),
                trailing: Icon(
                  Icons.sort_outlined,
                  size: 25,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => overweight(),
                  ),
                );
              },
              child: ListTile(
                leading: Icon(
                  Icons.local_drink_outlined,
                  size: 25,
                ),
                title: Text(
                  'Drinks',
                  style: TextStyle(fontSize: 25),
                ),
                trailing: Icon(
                  Icons.sort_outlined,
                  size: 25,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => overweight(),
                  ),
                );
              },
              child: ListTile(
                leading: Icon(
                  Icons.local_dining_outlined,
                  size: 25,
                ),
                title: Text(
                  'Meals',
                  style: TextStyle(fontSize: 25),
                ),
                trailing: Icon(
                  Icons.sort_outlined,
                  size: 25,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
