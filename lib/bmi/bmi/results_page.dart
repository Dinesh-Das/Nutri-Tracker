import 'package:flutter/material.dart';
import 'formula.dart';

class ResultPage extends StatefulWidget {
  int weight;
  int height;
  int age;
  ResultPage({required this.weight, required this.height, required this.age});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  Logic logic = Logic();
  double bmiResult = 0;
  @override
  void initState() {
    bmiResult = logic.CalculateBMI(widget.height, widget.weight);

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BMI CALCULATOR"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "BMI RESULT",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            Text(
              '${bmiResult.toStringAsFixed(1)}',
              style: TextStyle(fontSize: 65, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
