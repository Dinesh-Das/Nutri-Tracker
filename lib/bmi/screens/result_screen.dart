import 'package:flutter/material.dart';
import 'package:nutri_tracker/bmi/constants.dart';
import 'package:nutri_tracker/bmi/utils/reusable_card.dart';
import 'package:nutri_tracker/homepage/bottom_navigation.dart';

class ResultsPage extends StatelessWidget {
  ResultsPage(
      {required this.interpretation,
      required this.bmiResult,
      required this.resultText});

  final String bmiResult;
  final String resultText;
  final String interpretation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI CALCULATOR'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.all(15.0),
              alignment: Alignment.bottomLeft,
              child: Text(
                'Your Result',
                style: kTitleTextStyle,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: ReusableCard(
              colour: kActiveCardColour,
              cardChild: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    resultText.toUpperCase(),
                    style: kResultTextStyle,
                  ),
                  Text(
                    bmiResult,
                    style: kBMITextStyle,
                  ),
                  Text(
                    interpretation,
                    textAlign: TextAlign.center,
                    style: kBodyTextStyle,
                  ),
                ],
              ),
              onPress: () {},
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  child: Center(
                    child: Text(
                      'RE-CALCULATE',
                      style: kLargeButtonTextStyle,
                    ),
                  ),
                  color: kBottomContainerColour,
                  margin: EdgeInsets.only(top: 10.0),
                  padding: EdgeInsets.only(bottom: 20.0),
                  width: MediaQuery.of(context).size.width * 0.47,
                  height: kBottomContainerHeight,
                ),
              ),
              Divider(
                indent: 5,
                thickness: 1,
                height: 100,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BottomNavigation()));
                },
                child: Container(
                  child: Center(
                    child: Text(
                      'Continue',
                      style: kLargeButtonTextStyle,
                    ),
                  ),
                  color: kBottomContainerColour,
                  margin: EdgeInsets.only(top: 10.0),
                  padding: EdgeInsets.only(bottom: 20.0),
                  width: MediaQuery.of(context).size.width * 0.47,
                  height: kBottomContainerHeight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
