// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:nutri_tracker/drawer/drawermenu.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class home extends StatelessWidget {
  const home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('N U T R I T R A C K E R'),
        centerTitle: true,
        foregroundColor: Colors.green[900],
        backgroundColor: Colors.grey.withOpacity(0.8),
        elevation: 0,
      ),
      // drawer
      drawer: NavigationDrawer(),
      // backgroundColor: const Color(0xFFE9E9E9),
      body: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(40.0),
                bottomLeft: Radius.circular(40.0)),
            child: Container(
              height: 300,
              color: Colors.grey.withOpacity(0.8),
              child: PieChart(PieChartData(
                  // sections: getSections(),
                  )),
            ),
          ),
          // Section for additional logos
          ListView(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            scrollDirection: Axis.vertical,
            children: [
              SizedBox(
                height: 320,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 20.0),
                child: Text(
                  'Favourite Buttons',
                  style: TextStyle(
                      fontFamily: 'lato',
                      fontSize: 28.0,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey),
                ),
              ),
              Container(
                height: 200,
                padding: EdgeInsets.all(5),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(40.0)),
                  child: Container(
                    // padding: EdgeInsets.all(20.0),
                    color: Colors.deepPurpleAccent.withOpacity(0.3),
                    height: 250,
                    width: 50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 60.0),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: FaIcon(FontAwesomeIcons.hotdog),
                                splashColor: Colors.greenAccent[900],
                                iconSize: 40,
                              ),
                              SizedBox(width: 20.0),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.local_pizza_outlined,
                                ),
                                splashColor: Colors.greenAccent[900],
                                iconSize: 40,
                              ),
                              SizedBox(width: 20.0),
                              IconButton(
                                onPressed: () {},
                                icon: FaIcon(FontAwesomeIcons.amazonPay),
                                splashColor: Colors.greenAccent[900],
                                iconSize: 40,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 60.0, top: 20.0),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: FaIcon(FontAwesomeIcons.paypal),
                                splashColor: Colors.greenAccent[900],
                                iconSize: 40,
                              ),
                              SizedBox(width: 20.0),
                              IconButton(
                                onPressed: () {},
                                icon: FaIcon(FontAwesomeIcons.ccPaypal),
                                splashColor: Colors.greenAccent[900],
                                iconSize: 40,
                              ),
                              SizedBox(width: 20.0),
                              IconButton(
                                onPressed: () {},
                                icon: FaIcon(FontAwesomeIcons.googlePay),
                                splashColor: Colors.greenAccent[900],
                                iconSize: 40,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
