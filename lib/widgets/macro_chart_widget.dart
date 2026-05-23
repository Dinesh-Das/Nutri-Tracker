import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MacroChartWidget extends StatelessWidget {
  const MacroChartWidget({
    super.key,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.size = 140,
  });

  final double protein;
  final double carbs;
  final double fat;
  final double size;

  @override
  Widget build(BuildContext context) {
    final total = protein + carbs + fat;
    if (total <= 0) {
      return SizedBox(
        height: size,
        width: size,
        child: const Center(child: Text('No macros')),
      );
    }
    return SizedBox(
      height: size,
      width: size,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: size / 4,
          sections: [
            PieChartSectionData(
              value: protein,
              title: 'P',
              color: Colors.green,
              radius: size / 5,
            ),
            PieChartSectionData(
              value: carbs,
              title: 'C',
              color: Colors.orange,
              radius: size / 5,
            ),
            PieChartSectionData(
              value: fat,
              title: 'F',
              color: Colors.red,
              radius: size / 5,
            ),
          ],
        ),
      ),
    );
  }
}
