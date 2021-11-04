class UserModel {
  String? uid;
  String? email;
  String? name;
  String? mobile;
  String? photoURL;
  UserModel({this.uid, this.email, this.name, this.mobile, this.photoURL});

  //reciving data from server
  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      mobile: map['mobile'],
      photoURL: map['photoURL'],
    );
  }

  //sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'mobile': mobile,
      'photoURL': photoURL
    };
  }
}
