import 'package:cloud_firestore/cloud_firestore.dart';

class WeightEntry {
  WeightEntry({
    required this.weight,
    required this.bmi,
    required this.date,
    this.note = '',
  });

  final double weight;
  final double bmi;
  final DateTime date;
  final String note;

  factory WeightEntry.fromMap(Map<String, dynamic> map) {
    final date = map['date'];
    return WeightEntry(
      weight: (map['weight'] as num?)?.toDouble() ?? 0,
      bmi: (map['bmi'] as num?)?.toDouble() ?? 0,
      date: date is Timestamp ? date.toDate() : DateTime.now(),
      note: map['note'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'weight': weight,
      'bmi': bmi,
      'date': Timestamp.fromDate(date),
      'note': note,
    };
  }
}
