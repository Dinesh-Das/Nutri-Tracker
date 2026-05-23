import 'package:cloud_firestore/cloud_firestore.dart';

class FavouriteItem {
  FavouriteItem({
    required this.id,
    required this.type,
    required this.name,
    required this.imageUrl,
    this.sourceId,
    this.calories,
    DateTime? savedAt,
  }) : savedAt = savedAt ?? DateTime.now();

  final String id;
  final String type;
  final String name;
  final String imageUrl;
  final String? sourceId;
  final int? calories;
  final DateTime savedAt;

  factory FavouriteItem.fromMap(String id, Map<String, dynamic> map) {
    final savedAt = map['savedAt'];
    return FavouriteItem(
      id: id,
      type: map['type'] ?? 'food',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      sourceId: map['sourceId'],
      calories: (map['calories'] as num?)?.toInt(),
      savedAt: savedAt is Timestamp ? savedAt.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'imageUrl': imageUrl,
      'sourceId': sourceId,
      'calories': calories,
      'savedAt': Timestamp.fromDate(savedAt),
    };
  }
}
