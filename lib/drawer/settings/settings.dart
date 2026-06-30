import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/dark_theme/custom_theme.dart';
import 'package:nutri_tracker/drawer/profile/edit_profile.dart';
import 'package:nutri_tracker/drawer/settings/change_password.dart';
import 'package:nutri_tracker/drawer/settings/delete_user.dart';
import 'package:nutri_tracker/models/notification_settings.dart';
import 'package:nutri_tracker/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool setDarkTheme = currentTheme.isDarkTheme();
  String? _timezone;
  UserNotificationSettings _notificationSettings =
      const UserNotificationSettings();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('user_details')
        .doc(uid)
        .get();
    if (!mounted) return;
    final data = doc.data();
    setState(() {
      _timezone = data?['timezone'] as String?;
      _notificationSettings = UserNotificationSettings.fromMap(
        data?['notificationSettings'] is Map
            ? Map<String, dynamic>.from(data!['notificationSettings'])
            : null,
      );
    });
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
            _ReminderTile(
              title: 'Meal reminders',
              icon: Icons.restaurant_menu,
              preference: _notificationSettings.meal,
              onChanged: (preference) => _saveReminder(
                _notificationSettings.copyWith(meal: preference),
              ),
            ),
            _ReminderTile(
              title: 'Water reminders',
              icon: Icons.water_drop_outlined,
              preference: _notificationSettings.water,
              onChanged: (preference) => _saveReminder(
                _notificationSettings.copyWith(water: preference),
              ),
            ),
            _ReminderTile(
              title: 'Workout reminders',
              icon: Icons.fitness_center,
              preference: _notificationSettings.workout,
              showDays: true,
              onChanged: (preference) => _saveReminder(
                _notificationSettings.copyWith(workout: preference),
              ),
            ),
            _ReminderTile(
              title: 'Weigh-in reminder',
              icon: Icons.monitor_weight_outlined,
              preference: _notificationSettings.weighIn,
              onChanged: (preference) => _saveReminder(
                _notificationSettings.copyWith(weighIn: preference),
              ),
            ),
            _ReminderTile(
              title: 'Streak reminder',
              icon: Icons.local_fire_department_outlined,
              preference: _notificationSettings.streak,
              onChanged: (preference) => _saveReminder(
                _notificationSettings.copyWith(streak: preference),
              ),
            ),
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
    await NotificationService.instance.applySettings(
      _notificationSettings,
      timezone: timezone,
    );
  }

  Future<void> _saveReminder(UserNotificationSettings settings) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    setState(() => _notificationSettings = settings);
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('user_details').doc(uid).set({
      'uid': uid,
      'notificationSettings': settings.toMap(),
    }, SetOptions(merge: true));
    await NotificationService.instance.applySettings(
      settings,
      timezone: _timezone,
    );
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

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.title,
    required this.icon,
    required this.preference,
    required this.onChanged,
    this.showDays = false,
  });

  final String title;
  final IconData icon;
  final ReminderPreference preference;
  final ValueChanged<ReminderPreference> onChanged;
  final bool showDays;

  @override
  Widget build(BuildContext context) {
    final timeLabel = preference.time.format(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(icon),
              title: Text(title),
              subtitle: Text(timeLabel),
              value: preference.enabled,
              onChanged: (enabled) =>
                  onChanged(preference.copyWith(enabled: enabled)),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: preference.time,
                  );
                  if (picked == null) return;
                  onChanged(preference.copyWith(
                    hour: picked.hour,
                    minute: picked.minute,
                  ));
                },
                icon: const Icon(Icons.schedule),
                label: const Text('Change time'),
              ),
            ),
            if (showDays)
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  children: [
                    for (final day in const [
                      (1, 'Mon'),
                      (2, 'Tue'),
                      (3, 'Wed'),
                      (4, 'Thu'),
                      (5, 'Fri'),
                      (6, 'Sat'),
                      (7, 'Sun'),
                    ])
                      FilterChip(
                        selected: preference.days.contains(day.$1),
                        label: Text(day.$2),
                        onSelected: (selected) {
                          final days = [...preference.days];
                          selected ? days.add(day.$1) : days.remove(day.$1);
                          days.sort();
                          onChanged(preference.copyWith(days: days));
                        },
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
