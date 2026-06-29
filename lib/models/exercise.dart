class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.primaryMuscles,
    this.secondaryMuscles = const [],
    required this.equipment,
    required this.level,
    required this.instructions,
    this.formTips = const [],
    this.commonMistakes = const [],
    this.durationSeconds,
    this.defaultSets,
    this.defaultReps,
    required this.metValue,
    this.imageAsset,
    this.videoUrl,
    this.alternatives = const [],
  });

  final String id;
  final String name;
  final String category;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final String equipment;
  final String level;
  final List<String> instructions;
  final List<String> formTips;
  final List<String> commonMistakes;
  final int? durationSeconds;
  final int? defaultSets;
  final int? defaultReps;
  final double metValue;
  final String? imageAsset;
  final String? videoUrl;
  final List<String> alternatives;

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      category: map['category']?.toString() ?? 'strength',
      primaryMuscles: List<String>.from(map['primaryMuscles'] ?? const []),
      secondaryMuscles: List<String>.from(map['secondaryMuscles'] ?? const []),
      equipment: map['equipment']?.toString() ?? 'none',
      level: map['level']?.toString() ?? 'beginner',
      instructions: List<String>.from(map['instructions'] ?? const []),
      formTips: List<String>.from(map['formTips'] ?? const []),
      commonMistakes: List<String>.from(map['commonMistakes'] ?? const []),
      durationSeconds: (map['durationSeconds'] as num?)?.toInt(),
      defaultSets: (map['defaultSets'] as num?)?.toInt(),
      defaultReps: (map['defaultReps'] as num?)?.toInt(),
      metValue: (map['metValue'] as num?)?.toDouble() ?? 4,
      imageAsset: map['imageAsset']?.toString(),
      videoUrl: map['videoUrl']?.toString(),
      alternatives: List<String>.from(map['alternatives'] ?? const []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'primaryMuscles': primaryMuscles,
      'secondaryMuscles': secondaryMuscles,
      'equipment': equipment,
      'level': level,
      'instructions': instructions,
      'formTips': formTips,
      'commonMistakes': commonMistakes,
      'durationSeconds': durationSeconds,
      'defaultSets': defaultSets,
      'defaultReps': defaultReps,
      'metValue': metValue,
      'imageAsset': imageAsset,
      'videoUrl': videoUrl,
      'alternatives': alternatives,
    }..removeWhere((key, value) => value == null);
  }
}
