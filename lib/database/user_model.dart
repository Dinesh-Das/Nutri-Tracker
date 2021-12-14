class UserModel {
  String? uid;
  String? email;
  String? name;
  String? bmi;
  String? photoURL;
  String? username,
      bmr,
      gender,
      height,
      mobile,
      weight,
      birthdate,
      bio,
      location,
      creation;
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
    this.creation,
    this.bmr,
  });

  //reciving data from server
  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      bmi: map['bmi'],
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
      creation: map['creation'],
      bmr: map['bmr'],
    );
  }

  //sending data to our server
  Map<String, dynamic> toMap() {
    return {
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
      'creation': creation,
      'bmr': bmr,
    };
  }
}
