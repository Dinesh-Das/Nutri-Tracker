import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/dark_theme/custom_theme.dart';
import 'package:nutri_tracker/drawer/profile/edit_profile.dart';
import 'package:nutri_tracker/drawer/settings/change_password.dart';
import 'package:nutri_tracker/drawer/settings/delete_user.dart';
import 'package:nutri_tracker/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool setDarkTheme = currentTheme.isDarkTheme();
  bool setNotification = false;
  bool setRemainder = false;
  String? _timezone;

  @override
  void initState() {
    super.initState();
    _loadTimezone();
  }

  Future<void> _loadTimezone() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('user_details')
        .doc(uid)
        .get();
    if (!mounted) return;
    setState(() {
      _timezone = doc.data()?['timezone'] as String?;
    });
  }

  onNotificationChange(bool value) async {
    setState(() {
      setNotification = value;
    });
    if (value) {
      await NotificationService.instance
          .scheduleMealReminders(timezone: _timezone);
    } else {
      await NotificationService.instance.cancelMealReminders();
    }
  }

  onRemainderChange(bool value) async {
    setState(() {
      setRemainder = value;
    });
    if (value) {
      await NotificationService.instance
          .scheduleMealReminders(timezone: _timezone);
    } else {
      await NotificationService.instance.cancelMealReminders();
    }
  }

  @override
  Widget build(BuildContext context) {
    onThemeChange(bool value) {
      setState(() {
        setDarkTheme = value;
        currentTheme.toggleTheme();
      });
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text("Settings"),
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            const SizedBox(
              height: 40,
            ),
            const Row(
              children: [
                Icon(
                  Icons.person_outline,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Account",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                )
              ],
            ),
            const Divider(
              height: 20,
              thickness: 1,
            ),
            const SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EditProfile()));
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Edit Profile",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600]),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                    )
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChangePassword()));
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Change Password",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600]),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                    )
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                showAlertDialog(context);
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Delete Account",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600]),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            const Row(
              children: [
                Icon(
                  Icons.volume_up_outlined,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Notifications",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                )
              ],
            ),
            const Divider(
              height: 20,
              thickness: 1,
            ),
            const SizedBox(
              height: 10,
            ),
            buildNotificationOption("Dark Theme", setDarkTheme, onThemeChange),
            buildNotificationOption(
                "Notifications", setNotification, onNotificationChange),
            buildNotificationOption(
                "Reminders", setRemainder, onRemainderChange),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: DropdownButtonFormField<String>(
                value: _timezone,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Timezone override',
                  helperText: 'Leave blank to use device timezone',
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Use device timezone'),
                  ),
                  for (final zone
                      in tz.timeZoneDatabase.locations.keys.toList()..sort())
                    DropdownMenuItem(value: zone, child: Text(zone)),
                ],
                onChanged: _saveTimezone,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTimezone(String? timezone) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    setState(() => _timezone = timezone);
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('user_details').doc(uid).set({
      'uid': uid,
      'timezone': timezone,
    }, SetOptions(merge: true));
    if (setNotification || setRemainder) {
      await NotificationService.instance
          .scheduleMealReminders(timezone: timezone);
    }
  }

  Padding buildNotificationOption(
      String title, bool value, Function onChangeMethod) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600]),
          ),
          Transform.scale(
            scale: 0.7,
            child: CupertinoSwitch(
                activeColor: Colors.blue,
                trackColor: Colors.grey,
                value: value,
                onChanged: (bool newValue) {
                  onChangeMethod(newValue);
                }),
          ),
        ],
      ),
    );
  }
}
