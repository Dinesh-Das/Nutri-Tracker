import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutri_tracker/database/user_model.dart';

Future<UserModel?> getDataFromFirestore() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

  final doc = await FirebaseFirestore.instance
      .collection("user_details")
      .doc(user.uid)
      .get();

  return UserModel.fromMap(doc.data());
}
