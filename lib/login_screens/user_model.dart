class UserModel {
  String? uid;
  String? email;
  String? name;
  String? mobile;
  UserModel({this.uid, this.email, this.name, this.mobile});

  //reciving data from server
  factory UserModel.fromMap(map) {
    return UserModel(
        uid: map['uid'],
        email: map['email'],
        name: map['name'],
        mobile: map['mobile']);
  }

  //sending data to our server
  Map<String, dynamic> toMap() {
    return {'uid': uid, 'email': email, 'name': name, 'mobile': mobile};
  }
}
