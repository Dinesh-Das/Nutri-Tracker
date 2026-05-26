import 'package:flutter/material.dart';
import 'formula.dart';

class ResultPage extends StatefulWidget {
  final int weight;
  final int height;
  final int age;
  ResultPage(
      {super.key,
      required this.weight,
      required this.height,
      required this.age});

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
        title: const Text("BMI CALCULATOR"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "BMI RESULT",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            Text(
              bmiResult.toStringAsFixed(1),
              style: const TextStyle(fontSize: 65, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
