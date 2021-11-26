import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<String> get onAuthStateChanged =>
      FirebaseAuth.instance.userChanges().map(
            (User? user) => user!.uid,
          );

  //Get UID
  Future<String> getCurrentUID() async {
    return (await FirebaseAuth.instance.currentUser!.uid);
  }

//Get CurrentUser
  Future getCurrentUser() async {
    return await FirebaseAuth.instance.currentUser;
  }

// Email & Password Sign Up
  Future<String> createUserWithEmailAndPassword(
      String email, String password, String name) async {
    final authResult =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Update the username
    await updateUserName(name, authResult.user);
    return authResult.user!.uid;
  }

  Future updateUserName(String? name, User? currentUser) async {
    // var userUpdateInfo = UserUpdateInfo();
    // userUpdateInfo.displayName = name;
    await currentUser!.updateDisplayName(name);
    await currentUser.reload();
  }

// Email & Password Sign In
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    return (await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password))
        .user!
        .uid;
  }

// Sign Out
  signOut() {
    return FirebaseAuth.instance.signOut();
  }

// Create Anonymous User
  Future singInAnonymously() {
    return FirebaseAuth.instance.signInAnonymously();
  }

  Future convertUserWithEmail(
      String email, String password, String? name) async {
    final currentUser = await FirebaseAuth.instance.currentUser!;

    final credential =
        EmailAuthProvider.credential(email: email, password: password);
    await currentUser.linkWithCredential(credential);
    await updateUserName(name!, currentUser);
  }

  Future convertWithGoogle() async {
    final currentUser = await FirebaseAuth.instance.currentUser!;
    final GoogleSignInAccount? account = await _googleSignIn.signIn();
    final GoogleSignInAuthentication _googleAuth =
        await account!.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: _googleAuth.idToken,
      accessToken: _googleAuth.accessToken,
    );
    await currentUser.linkWithCredential(credential);
    await updateUserName(_googleSignIn.currentUser!.displayName, currentUser);
  }

  // GOOGLE
  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount? account = await _googleSignIn.signIn();
    final GoogleSignInAuthentication _googleAuth =
        await account!.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: _googleAuth.idToken,
      accessToken: _googleAuth.accessToken,
    );
    return (await _firebaseAuth.signInWithCredential(credential)).user!.uid;
  }
}
