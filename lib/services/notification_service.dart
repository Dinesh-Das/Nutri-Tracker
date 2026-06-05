import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_tracker/router/app_router.dart';
import 'package:nutri_tracker/routes/app_routes.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        rootNavigatorKey.currentContext?.go(payload);
      },
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleMealReminders({String? timezone}) async {
    final location = _locationFor(timezone);
    await _scheduleDaily(
      0,
      8,
      0,
      'NutriTrack India',
      'Time for breakfast! Log your morning meal.',
      location,
    );
    await _scheduleDaily(
      1,
      13,
      0,
      'NutriTrack India',
      "Lunch time! Don't forget to log your meal.",
      location,
    );
    await _scheduleDaily(
      2,
      19,
      30,
      'NutriTrack India',
      "Log your dinner to complete today's tracking.",
      location,
    );
  }

  Future<void> cancelMealReminders() => _plugin.cancelAll();

  Future<void> showAchievement(String title, String body) {
    return _plugin.show(
      1000 + DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'achievements',
          'Achievements',
          channelDescription: 'NutriTrack India achievement milestones',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> _scheduleDaily(
    int id,
    int hour,
    int minute,
    String title,
    String body,
    tz.Location location,
  ) {
    return _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute, location),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'meal_reminders',
          'Meal Reminders',
          channelDescription: 'Daily NutriTrack India meal reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: AppRoutes.calorieLog,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(
    int hour,
    int minute,
    tz.Location location,
  ) {
    final now = tz.TZDateTime.now(location);
    var scheduled =
        tz.TZDateTime(location, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.Location _locationFor(String? timezone) {
    if (timezone == null || timezone.trim().isEmpty) return tz.local;
    try {
      return tz.getLocation(timezone);
    } catch (_) {
      return tz.local;
    }
  }
}
