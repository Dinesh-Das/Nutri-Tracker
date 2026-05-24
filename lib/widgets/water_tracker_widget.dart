import 'package:flutter/material.dart';
import 'package:nutri_tracker/services/calorie_service.dart';

class WaterTrackerWidget extends StatelessWidget {
  const WaterTrackerWidget({
    super.key,
    required this.uid,
    required this.date,
    required this.waterIntakeMl,
  });

  final String uid;
  final DateTime date;
  final int waterIntakeMl;

  @override
  Widget build(BuildContext context) {
    final cups = (waterIntakeMl / 250).round().clamp(0, 8);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Water', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: List.generate(8, (index) {
            final filled = index < cups;
            return IconButton(
              tooltip: '${index + 1} cups',
              onPressed: () {
                final nextCups =
                    filled && index == cups - 1 ? index : index + 1;
                CalorieService().updateWaterIntake(uid, date, nextCups);
              },
              icon: Icon(
                filled ? Icons.water_drop : Icons.water_drop_outlined,
                color: filled ? Colors.blue : Colors.grey,
              ),
            );
          }),
        ),
        Text('${cups * 250}ml / 2000ml goal'),
      ],
    );
  }
}
