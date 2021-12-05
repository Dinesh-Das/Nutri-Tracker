import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/constants.dart';
import 'package:nutri_tracker/drawer/AboutUs/aboutus01.dart';
import 'package:nutri_tracker/drawer/profile/edit_profile.dart';
import 'package:nutri_tracker/drawer/profile/view_profile.dart';
import 'package:nutri_tracker/drawer/settings/settings.dart';
import 'package:nutri_tracker/database/google_signin.dart';
import 'package:nutri_tracker/login_screens/login_page.dart';
import 'package:nutri_tracker/database/user_model.dart';
// import 'package:nutri_tracker/bottom_navigation.dart';
import 'package:nutri_tracker/sharedPreferences/local_data.dart';
import 'package:nutri_tracker/sharedPreferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../homepage/bottom_navigation.dart';

class NavigationDrawer extends StatefulWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

  @override
  _NavigationDrawerState createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  //Displaying data from database
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  String? name = '';
  String? email = '';
  String? urlImage = '';
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
    //Email Passward data
    name = '${loggedInUser.name}';
    email = '${loggedInUser.email}';
    urlImage =
        loggedInUser.photoURL == '' ? defaultProfileUrl : loggedInUser.photoURL;

    //google account data
    user = FirebaseAuth.instance.currentUser!;
    if (user!.providerData[0].providerId == "google.com") {
      final provider =
          Provider.of<GoogleSignInProvider>(context, listen: false);
      email = provider.userModel?.email!;
      name = provider.userModel?.name!;
      urlImage = provider.userModel?.photoURL!;
    }

    if (email == null) {
      name = DataConstant.gname.toString();
      email = DataConstant.gmail.toString();
      urlImage = DataConstant.gimg.toString();
    }
    return Drawer(
      elevation: 0,
      child: Material(
        color: Theme.of(context).primaryColorDark,
        child: ListView(
          children: <Widget>[
            Container(
              padding: padding,
              child: Column(
                children: [
                  buildHeader(
                      urlImage: urlImage.toString(),
                      name: name.toString(),
                      email: email.toString(),
                      onClicked: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ViewProfile()))),
                  const SizedBox(
                    height: 13,
                  ),
                  buildMenuItem(
                    context: context,
                    text: 'Edit Profile',
                    icon: Icons.edit,
                    onClicked: () => selectedItem(context, 0),
                  ),
                  const SizedBox(
                    height: 13,
                  ),
                  buildMenuItem(
                    context: context,
                    text: 'Settings',
                    icon: Icons.settings,
                    onClicked: () => selectedItem(context, 2),
                  ),
                  const SizedBox(
                    height: 13,
                  ),
                  buildMenuItem(
                    context: context,
                    text: 'Support',
                    icon: Icons.support_agent_sharp,
                    onClicked: () => selectedItem(context, 1),
                  ),
                  const SizedBox(
                    height: 13,
                  ),
                  buildMenuItem(
                    context: context,
                    text: 'Logout',
                    icon: Icons.logout,
                    onClicked: () => logout(context),
                  ),
                  const SizedBox(
                    height: 13,
                  ),
                  const Divider(
                    thickness: 2.5,
                  ),
                  const SizedBox(
                    height: 13,
                  ),
                  buildMenuItem(
                    context: context,
                    text: 'Share',
                    icon: Icons.share,
                    onClicked: () => selectedItem(context, 3),
                  ),
                  const SizedBox(
                    height: 13,
                  ),
                  buildMenuItem(
                    context: context,
                    text: 'About App',
                    icon: Icons.workspaces_outline,
                    onClicked: () => selectedItem(context, 4),
                  ),
                  const SizedBox(
                    height: 13,
                  ),
                  buildMenuItem(
                      context: context,
                      text: 'About Us',
                      icon: Icons.developer_mode,
                      onClicked: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Aboutus01()));
                      }),
                  const SizedBox(
                    height: 10,
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
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.clear();
    sharedPreferences.remove('logintype');
    user = await FirebaseAuth.instance.currentUser!;
    if (user!.providerData[0].providerId == "google.com") {
      final provider =
          Provider.of<GoogleSignInProvider>(context, listen: false);
      provider.googleLogOut();
    }
    UserLocalData.saveLoginData(false);
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }
}

Widget buildHeader({
  required String urlImage,
  required String name,
  required String email,
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
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                email,
                style: const TextStyle(fontSize: 11),
              ),
            ])
          ],
        ),
      ),
    );

Widget buildMenuItem({
  required String text,
  required IconData icon,
  required BuildContext context,
  VoidCallback? onClicked,
}) {
  return ListTile(
    leading: Icon(
      icon,
      color: Theme.of(context).iconTheme.color,
    ),
    title: Text(text),
    onTap: onClicked,
  );
}

void selectedItem(BuildContext context, int index) {
  Navigator.of(context).pop();
  switch (index) {
    case 0:
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const EditProfile()));
      break;
    case 1:
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => BottomNavigation()));
      break;
    case 2:
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const SettingsPage()));
      break;
    case 3:
      Share.share(
          'https://drive.google.com/file/d/18XAjRC9_k825xVOZMFBFTpMPzi4xBvOm/view?usp=sharing');
      break;
    case 4:
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => BottomNavigation()));
      break;
  }
}
