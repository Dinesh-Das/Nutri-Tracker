import 'dart:math';

import 'dart:math';

class Logic {
  double CalculateBMI(int height, int weight) {
    double bmi = weight / pow(height / 100, 2);
    return bmi;
  }
}
