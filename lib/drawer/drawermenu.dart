import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/drawer/AboutUs/aboutus01.dart';
import 'package:nutri_tracker/drawer/chk.dart';
import 'package:nutri_tracker/drawer/profile/edit_profile.dart';
import 'package:nutri_tracker/drawer/profile/view_profile.dart';
import 'package:nutri_tracker/drawer/settings/settings.dart';
import 'package:nutri_tracker/login_screens/google_signin/google_signin.dart';
import 'package:nutri_tracker/login_screens/login_page.dart';
import 'package:nutri_tracker/login_screens/user.dart';
import 'package:nutri_tracker/login_screens/user_model.dart';
import 'package:nutri_tracker/onbparding_components/content_model.dart';
import 'package:nutri_tracker/screens/home.dart';
import 'package:nutri_tracker/sharedPreferences/constant.dart';
import 'package:nutri_tracker/sharedPreferences/shared.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationDrawer extends StatefulWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

  @override
  _NavigationDrawerState createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  //Displaying data from database
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  late String? name;
  late String? email;
  late String? urlImage;
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

  Future<bool?> setValues() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int log = sharedPreferences.getInt('logintype')!;
    if (log == 2) return true;
    return false;
  }

  final padding = const EdgeInsets.symmetric(horizontal: 20);

  @override
  Widget build(BuildContext context) {
    bool logintype = true;
    name = logintype ? '${loggedInUser.name}' : '${DataConstant.gname}';
    email = logintype ? '${loggedInUser.email}' : '${DataConstant.gmail}';
    urlImage = logintype ? '${loggedInUser.photoURL}' : '${DataConstant.gimg}';
    user = FirebaseAuth.instance.currentUser!;
    if (user!.providerData[0].providerId == "google.com") {
      final provider =
          Provider.of<GoogleSignInProvider>(context, listen: false);
      email = provider.userModel?.email;
      name = provider.userModel?.name;
      urlImage = provider.userModel?.photoURL;
    }
    Future<bool?> balue = setValues();
    String val = balue.toString();
    if (val == balue) {
      name = DataConstant.gname.toString();
      email = DataConstant.gmail.toString();
      urlImage = DataConstant.gimg.toString();
    }
    return Drawer(
      child: Material(
        color: Colors.black45,
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
                              builder: (context) => ViewProfile(
                                  // name: name,
                                  // urlImage: urlImage,
                                  )))),
                  const SizedBox(
                    height: 10,
                  ),
                  buildMenuItem(
                    text: 'Edit Profile',
                    icon: Icons.edit,
                    onClicked: () => selectedItem(context, 0),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  buildMenuItem(
                    text: 'Favourites',
                    icon: Icons.favorite_border,
                    onClicked: () => selectedItem(context, 1),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  buildMenuItem(
                    text: 'Workflow',
                    icon: Icons.workspaces_outline,
                    onClicked: () => selectedItem(context, 2),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  buildMenuItem(
                    text: 'Settings',
                    icon: Icons.settings,
                    onClicked: () => selectedItem(context, 3),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  buildMenuItem(
                    text: 'Logout',
                    icon: Icons.logout,
                    onClicked: () => logout(context),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Divider(
                    color: Colors.white70,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  buildMenuItem(
                    text: 'Share',
                    icon: Icons.share,
                    onClicked: () => selectedItem(context, 5),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  buildMenuItem(
                    text: 'About App',
                    icon: Icons.workspaces_outline,
                    onClicked: () => selectedItem(context, 6),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  buildMenuItem(
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
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                email,
                style: const TextStyle(fontSize: 11, color: Colors.white),
              ),
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
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const EditProfile()));
      break;
    case 1:
      Navigator.push(context, MaterialPageRoute(builder: (context) => home()));
      break;
    case 2:
      Navigator.push(context, MaterialPageRoute(builder: (context) => Chk()));
      break;
    case 3:
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const SettingsPage()));
      break;
    case 5:
      Share.share(
          'https://drive.google.com/file/d/18XAjRC9_k825xVOZMFBFTpMPzi4xBvOm/view?usp=sharing');
      break;
    case 6:
      Navigator.push(context, MaterialPageRoute(builder: (context) => home()));
      break;
  }
}
