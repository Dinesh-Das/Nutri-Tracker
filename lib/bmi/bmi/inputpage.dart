// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'enum_file.dart';
import 'results_page.dart';

class InputPage extends StatefulWidget {
  InputPage({Key? key}) : super(key: key);

  @override
  _InputPageState createState() => _InputPageState();
}

enum Gender { male, female }

class _InputPageState extends State<InputPage> {
  Gender selectedCard = Gender.male;
  int sliderValue = 120;
  int weight = 40;
  int age = 25;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BMI CALCULATOR"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCard = Gender.male;
                      });
                    },
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.mars,
                              color: Colors.white, size: 95),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "MALE",
                            style: TextStyle(color: Colors.white, fontSize: 21),
                          ),
                        ],
                      ),
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: selectedCard == Gender.male
                            ? Colors.lightGreen
                            : Colors.lightBlueAccent,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCard = Gender.female;
                      });
                    },
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.venus,
                              color: Colors.white, size: 95),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "FEMALE",
                            style: TextStyle(color: Colors.white, fontSize: 21),
                          ),
                        ],
                      ),
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: selectedCard == Gender.female
                            ? Colors.lightGreen
                            : Colors.lightBlueAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "HEIGHT",
                          style: TextStyle(color: Colors.white, fontSize: 21),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              sliderValue.toString(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 60,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "cm",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 21),
                            )
                          ],
                        ),
                        Slider(
                          value: sliderValue.toDouble(),
                          min: 120.0,
                          max: 225.0,
                          onChanged: (value) {
                            setState(() {
                              sliderValue = value.toInt();
                            });
                          },
                          inactiveColor: Colors.white,
                        ),
                      ],
                    ),
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "WEIGHT",
                          style: TextStyle(color: Colors.white, fontSize: 21),
                        ),
                        Text(
                          "$weight",
                          style: TextStyle(
                              fontSize: 60,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  weight++;
                                });
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 25,
                                child: Icon(
                                  FontAwesomeIcons.plus,
                                  color: Colors.lightBlue,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  weight--;
                                });
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 25,
                                child: Icon(
                                  FontAwesomeIcons.minus,
                                  color: Colors.lightBlue,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "AGE",
                          style: TextStyle(color: Colors.white, fontSize: 21),
                        ),
                        Text(
                          "$age",
                          style: TextStyle(
                              fontSize: 60,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  age++;
                                });
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 25,
                                child: Icon(
                                  FontAwesomeIcons.plus,
                                  color: Colors.lightBlue,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  age--;
                                });
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 25,
                                child: Icon(
                                  FontAwesomeIcons.minus,
                                  color: Colors.lightBlue,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ResultPage(
                          height: sliderValue,
                          weight: weight,
                          age: age,
                        )),
              );
            },
            child: Container(
              margin: EdgeInsets.all(10),
              color: Colors.blue,
              height: 80,
              width: double.infinity,
              child: Center(
                child: Text(
                  "CALCULATE",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
