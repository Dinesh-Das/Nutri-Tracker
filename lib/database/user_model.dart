import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? uid;
  String? email;
  String? name;
  double? bmi;
  String? photoURL;
  String? username;
  double? bmr;
  String? gender;
  String? height;
  String? mobile;
  String? weight;
  String? birthdate;
  String? bio;
  String? location;
  double? targetWeight;
  String? activityLevel;
  String? dietaryPreference;
  List<String>? allergies;
  int? dailyCalorieGoal;
  String? fitnessLevel;
  String? equipment;
  List<String>? preferredWorkoutDays;
  int? workoutsPerWeek;
  int? workoutDurationMinutes;
  String? injuriesOrLimitations;
  bool? isAdmin;
  DateTime? lastBmiDate;
  String? weightGoal;
  bool? isOnboardingDone;
  String? timezone;

  UserModel({
    this.uid,
    this.bmi,
    this.email,
    this.name,
    this.mobile,
    this.photoURL,
    this.gender,
    this.height,
    this.username,
    this.weight,
    this.birthdate,
    this.bio,
    this.location,
    this.bmr,
    this.targetWeight,
    this.activityLevel,
    this.dietaryPreference,
    this.allergies,
    this.dailyCalorieGoal,
    this.fitnessLevel,
    this.equipment,
    this.preferredWorkoutDays,
    this.workoutsPerWeek,
    this.workoutDurationMinutes,
    this.injuriesOrLimitations,
    this.isAdmin,
    this.lastBmiDate,
    this.weightGoal,
    this.isOnboardingDone,
    this.timezone,
  });

  //reciving data from server
  factory UserModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return UserModel();
    final lastBmiValue = map['lastBmiDate'];
    return UserModel(
      uid: map['uid'],
      bmi: _toDouble(map['bmi']),
      email: map['email'],
      name: map['name'],
      mobile: map['mobile'],
      photoURL: map['photoURL'],
      gender: map['gender'],
      height: map['height'],
      weight: map['weight'],
      username: map['username'],
      birthdate: map['birthdate'],
      bio: map['bio'],
      location: map['location'],
      bmr: _toDouble(map['bmr']),
      targetWeight: (map['targetWeight'] as num?)?.toDouble(),
      activityLevel: map['activityLevel'],
      dietaryPreference: map['dietaryPreference'],
      allergies: List<String>.from(map['allergies'] ?? const []),
      dailyCalorieGoal: (map['dailyCalorieGoal'] as num?)?.toInt(),
      fitnessLevel: map['fitnessLevel'],
      equipment: map['equipment'],
      preferredWorkoutDays:
          List<String>.from(map['preferredWorkoutDays'] ?? const []),
      workoutsPerWeek: (map['workoutsPerWeek'] as num?)?.toInt(),
      workoutDurationMinutes: (map['workoutDurationMinutes'] as num?)?.toInt(),
      injuriesOrLimitations: map['injuriesOrLimitations'],
      isAdmin: map['isAdmin'] == true,
      lastBmiDate: lastBmiValue is Timestamp
          ? lastBmiValue.toDate()
          : lastBmiValue is DateTime
              ? lastBmiValue
              : null,
      weightGoal: map['weightGoal'],
      isOnboardingDone: map['isOnboardingDone'] == true,
      timezone: map['timezone'],
    );
  }

  // Sending data to Firestore. Null values and client-owned protected fields
  // are omitted so profile edits do not erase existing server data.
  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'uid': uid,
      'bmi': bmi,
      'email': email,
      'name': name,
      'mobile': mobile,
      'photoURL': photoURL,
      'gender': gender,
      'height': height,
      'weight': weight,
      'username': username,
      'birthdate': birthdate,
      'bio': bio,
      'location': location,
      'bmr': bmr,
      'targetWeight': targetWeight,
      'activityLevel': activityLevel,
      'dietaryPreference': dietaryPreference,
      'allergies': allergies,
      'dailyCalorieGoal': dailyCalorieGoal,
      'fitnessLevel': fitnessLevel,
      'equipment': equipment,
      'preferredWorkoutDays': preferredWorkoutDays,
      'workoutsPerWeek': workoutsPerWeek,
      'workoutDurationMinutes': workoutDurationMinutes,
      'injuriesOrLimitations': injuriesOrLimitations,
      'lastBmiDate':
          lastBmiDate == null ? null : Timestamp.fromDate(lastBmiDate!),
      'weightGoal': weightGoal,
      'isOnboardingDone': isOnboardingDone,
      'timezone': timezone,
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
