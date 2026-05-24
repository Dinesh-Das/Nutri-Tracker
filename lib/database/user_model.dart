import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? uid;
  String? email;
  String? name;
  String? bmi;
  String? photoURL;
  String? username;
  String? bmr;
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
  bool? isAdmin;
  DateTime? lastBmiDate;
  String? weightGoal;
  bool? isOnboardingDone;

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
    this.isAdmin,
    this.lastBmiDate,
    this.weightGoal,
    this.isOnboardingDone,
  });

  //reciving data from server
  factory UserModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return UserModel();
    final lastBmiValue = map['lastBmiDate'];
    return UserModel(
      uid: map['uid'],
      bmi: map['bmi']?.toString(),
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
      bmr: map['bmr']?.toString(),
      targetWeight: (map['targetWeight'] as num?)?.toDouble(),
      activityLevel: map['activityLevel'],
      dietaryPreference: map['dietaryPreference'],
      allergies: List<String>.from(map['allergies'] ?? const []),
      dailyCalorieGoal: (map['dailyCalorieGoal'] as num?)?.toInt(),
      isAdmin: map['isAdmin'] == true,
      lastBmiDate: lastBmiValue is Timestamp
          ? lastBmiValue.toDate()
          : lastBmiValue is DateTime
              ? lastBmiValue
              : null,
      weightGoal: map['weightGoal'],
      isOnboardingDone: map['isOnboardingDone'] == true,
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
      'lastBmiDate':
          lastBmiDate == null ? null : Timestamp.fromDate(lastBmiDate!),
      'weightGoal': weightGoal,
      'isOnboardingDone': isOnboardingDone,
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }
}
