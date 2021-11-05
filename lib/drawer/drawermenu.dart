import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/login_screens/google_signin/google_signin.dart';
import 'package:nutri_tracker/login_screens/login_page.dart';
import 'package:nutri_tracker/login_screens/user.dart';
import 'package:nutri_tracker/login_screens/user_model.dart';
import 'package:nutri_tracker/screens/home.dart';
import 'package:provider/provider.dart';

class NavigationDrawer extends StatefulWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

  @override
  _NavigationDrawerState createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  //Displaying data from database
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("user_details")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  final padding = const EdgeInsets.symmetric(horizontal: 20);

  @override
  Widget build(BuildContext context) {
    bool isGoogleSignin = false;
    var name = isGoogleSignin ? '' : '${loggedInUser.name}';
    var email = isGoogleSignin ? '' : '${loggedInUser.email}';
    var mobile = isGoogleSignin ? '' : '${loggedInUser.mobile}';
    var urlImage = isGoogleSignin
        ? ''
        : 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAAM1BMVEXk5ueutLeqsbTn6eqpr7PJzc/j5ebf4eLZ3N2wtrnBxsjN0NLGysy6v8HT1tissra8wMNxTKO9AAAFDklEQVR4nO2d3XqDIAxAlfivoO//tEOZWzvbVTEpic252W3PF0gAIcsyRVEURVEURVEURVEURVEURVEURVEURVEURVEURflgAFL/AirAqzXO9R7XNBVcy9TbuMHmxjN6lr92cNVVLKEurVfK/zCORVvW8iUBnC02dj+Wpu0z0Y6QlaN5phcwZqjkOkK5HZyPAjkIjSO4fIdfcOwFKkJlX4zPu7Ha1tIcwR3wWxyFhRG6g4Je0YpSPDJCV8a2Sv2zd1O1x/2WMDZCwljH+clRrHfWCLGK8REMiql//2si5+DKWKcWeAGcFMzzNrXC/0TUwQ2s6+LhlcwjTMlYsUIQzPOCb7YBiyHopyLXIEKPEkI/TgeuiidK/R9FniUDOjRDpvm0RhqjMyyXNjDhCfIMYl1gGjIMIuYsnGEYRMRZOMMunaLVwpWRW008v6fYKDIzxCwVAeNSO90BJW6emelYBRF/kHpYGVaoxTDAaxOFsfP9y8hpJ4xd7gOcij7JNGQ1EYFgkPJa1jQEiYZXRaRINKxSDUW9n+FT82lSKadkiru9/4XPqSLWOekGPoY05TAvLm9orm+YWuwHoBHkZKijNBJGmeb61eL6Ff/6q7bLr7yvv3vKGhpDRjvgjGaPz+gUg6YgcvpyAR2FIZ9U6nEEyZRTovmEU32KichpGn7C17XrfyH9gK/c0CMP05HZIM2uf9sEveizKveBy9/6Qt7o89ne33D525cfcIMW6ab+TMEukQbQbu+xu7X3A9bChmWaCeAkG17bpntwXgWxHaMzGPmUaR5dQZiKqRVeUZ3047fi3nAu28h4CHxCsZAgmEH8Y27jJAhm8c+5RQzRQNVGhVFSfxOYIjp/pP7RxzjevYXVGf4eLt+BJ1vCuLuLkrgABgCGXZ2wik5uty+oBvNirI6mkzhAf4Gsb58Hcm67Jzd+KwD10BYPLL3e0MjvKrgAULnOfveF/O4N2Xb9BZom3gJes3F9X5Zze8/6Yt09b4CrqsEjUv8oFBaR2rl+6CZr2xVrp24o/WitBKuGrrpl1+bFkmK2qXTON4VpbdfLa7o7y/WdLxG7lm2Lqh2clOwTegbvc/vj2U78CwhA87Bn8G5Nk3eOb0Nsr9flz3sG78UUtue4kpv1xvjg3TMay62BMlTlP+vrOMnJsRmt/ze0jsfkPPYdAH57hK+34PeOyc8XIXu5xT2HsUkdZz+adwg8HGFfQ3K5jtDvbUiO4Di9/ywHGrL88pDizZ++oTp+an+SMX/ndymUCwmHMdO7yuOx83pUx/eEMU0AvxWndwgidAqOZ8ypCwdEfvvEo6D9HwpA8wzvmOJEqAg9ySu8g4x0Hb9hSB/BANEKJ+LbPBU0lzbAJs4xt1AoshKkUGQmiH8/jJ0gdhTTLmSegHlPE0oOdXALnqDjKYh3px//fSgSWG8UqfrrIICzYYSJXRr9BSPbpNzw7gBjKjKOYI7ReIGqQRIap5+5MdjyvuDkExvGeXSlONWZAP3/AZBwJohU7QJRGU+cTVH18ELmRPNBmibW6MT/k1b0XhdkRBvyT6SB6EYv/GvhSmRNpGngRULsAlxMCGNXp7w3FfdEbTEEDdLI9TdIKRUzUesa3I461ER8cpNT7gMRhpKmYVS9ELOgCUQsa4SsulciKiLbY+AnHD8cpuhISsnxpamI84sbDq9qYJgf8wiiOBrC7Ml7M7ZECCqKoiiKoiiKoiiKoijv5AvJxlZRyNWWLwAAAABJRU5ErkJggg==';
    user = FirebaseAuth.instance.currentUser!;

    if (user!.providerData[0].providerId == "google.com") {
      final provider =
          Provider.of<GoogleSignInProvider>(context, listen: false);
      isGoogleSignin = true;
      email = provider.userModel!.email!;
      name = provider.userModel!.name!;
      urlImage = provider.userModel!.photoURL!;
    }
    return Drawer(
      child: Material(
        color: Colors.green,
        child: ListView(
          children: <Widget>[
            Container(
              padding: padding,
              child: Column(
                children: [
                  buildHeader(
                      urlImage: urlImage,
                      name: name,
                      email: email,
                      mobile: mobile,
                      onClicked: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserPage(
                                    name: name,
                                    urlImage: urlImage,
                                  )))),
                  const SizedBox(
                    height: 12,
                  ),
                  buildMenuItem(
                    text: 'People',
                    icon: Icons.people,
                    onClicked: () => selectedItem(context, 0),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  buildMenuItem(
                    text: 'Favourites',
                    icon: Icons.favorite_border,
                    onClicked: () => selectedItem(context, 1),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  buildMenuItem(
                    text: 'Workflow',
                    icon: Icons.workspaces_outline,
                    onClicked: () => selectedItem(context, 2),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  buildMenuItem(
                    text: 'Updates',
                    icon: Icons.update,
                    onClicked: () => selectedItem(context, 3),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  buildMenuItem(
                    text: 'Logout',
                    icon: Icons.logout,
                    onClicked: () => logout(context),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  const Divider(
                    color: Colors.white70,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  buildMenuItem(
                    text: 'Favourites',
                    icon: Icons.favorite_border,
                    onClicked: () => selectedItem(context, 5),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  buildMenuItem(
                    text: 'Workflow',
                    icon: Icons.workspaces_outline,
                    onClicked: () => selectedItem(context, 6),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  buildMenuItem(
                    text: 'Updates',
                    icon: Icons.update,
                    onClicked: () => selectedItem(context, 7),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    user = await FirebaseAuth.instance.currentUser!;
    if (user!.providerData[0].providerId == "google.com") {
      final provider =
          Provider.of<GoogleSignInProvider>(context, listen: false);
      provider.googleLogOut();
    }
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }
}

Widget buildHeader({
  required String urlImage,
  required String name,
  required String email,
  String? mobile,
  required VoidCallback onClicked,
}) =>
    InkWell(
      onTap: onClicked,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 30, backgroundImage: NetworkImage(urlImage)),
            const SizedBox(width: 20),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                name,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                email,
                style: const TextStyle(fontSize: 11, color: Colors.white),
              ),
              Text(
                mobile.toString(),
                style: const TextStyle(fontSize: 14, color: Colors.white),
              )
            ])
          ],
        ),
      ),
    );

Widget buildMenuItem({
  required String text,
  required IconData icon,
  VoidCallback? onClicked,
}) {
  final color = Colors.white;
  final hoverColor = Colors.white70;

  return ListTile(
    leading: Icon(
      icon,
      color: color,
    ),
    title: Text(
      text,
      style: TextStyle(color: color),
    ),
    onTap: onClicked,
    hoverColor: hoverColor,
  );
}

void selectedItem(BuildContext context, int index) {
  Navigator.of(context).pop();
  switch (index) {
    case 0:
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const home()));
      break;
    case 1:
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const home()));
      break;
    case 2:
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const home()));
      break;
    case 3:
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const home()));
      break;
    case 5:
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const home()));
      break;
    case 6:
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const home()));
      break;
    case 7:
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const home()));
      break;
  }
}
