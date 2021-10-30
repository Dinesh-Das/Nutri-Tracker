import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/login_screens/login_page.dart';
import 'package:nutri_tracker/login_screens/user.dart';
import 'package:nutri_tracker/login_screens/user_model.dart';
import 'package:nutri_tracker/screens/home.dart';

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
    final name = '${loggedInUser.name}';
    final email = '${loggedInUser.email}';
    final mobile = '${loggedInUser.mobile}';
    final urlImage =
        'https://i.guim.co.uk/img/media/569482766443924ffb15e7ac6ab35adffd6872c6/109_13_2891_1734/master/2891.jpg?width=1200&height=1200&quality=85&auto=format&fit=crop&s=e771b8693164168ed269a859a5639f61';

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
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                email,
                style: const TextStyle(fontSize: 14, color: Colors.white),
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
