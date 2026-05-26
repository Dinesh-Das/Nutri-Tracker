import 'package:flutter/material.dart';
import 'package:nutri_tracker/utils/health_utils.dart';

class BmiGaugeWidget extends StatelessWidget {
  const BmiGaugeWidget({super.key, required this.bmi});

  final double bmi;

  @override
  Widget build(BuildContext context) {
    final normalized = ((bmi - 16) / 24).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              bmi > 0 ? bmi.toStringAsFixed(1) : 'Not set',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Chip(
              label: Text(getBmiCategory(bmi)),
              backgroundColor: getBmiColor(bmi).withOpacity(0.15),
              side: BorderSide(color: getBmiColor(bmi)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              const Row(
                children: [
                  Expanded(
                      child: ColoredBox(
                          color: Colors.blue, child: SizedBox(height: 10))),
                  Expanded(
                      child: ColoredBox(
                          color: Colors.green, child: SizedBox(height: 10))),
                  Expanded(
                      child: ColoredBox(
                          color: Colors.orange, child: SizedBox(height: 10))),
                  Expanded(
                      child: ColoredBox(
                          color: Colors.red, child: SizedBox(height: 10))),
                ],
              ),
              FractionallySizedBox(
                widthFactor: normalized,
                child: Container(height: 10, alignment: Alignment.centerRight),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('16'),
            Text('18.5'),
            Text('25'),
            Text('30'),
            Text('40')
          ],
        ),
      ],
    );
  }
}
