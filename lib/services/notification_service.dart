import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_tracker/models/notification_settings.dart';
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
      _mealReminderIds[0],
      8,
      0,
      'NutriTrack India',
      'Time for breakfast! Log your morning meal.',
      location,
    );
    await _scheduleDaily(
      _mealReminderIds[1],
      13,
      0,
      'NutriTrack India',
      "Lunch time! Don't forget to log your meal.",
      location,
    );
    await _scheduleDaily(
      _mealReminderIds[2],
      19,
      30,
      'NutriTrack India',
      "Log your dinner to complete today's tracking.",
      location,
    );
  }

  Future<void> scheduleWorkoutReminder({
    int hour = 18,
    int minute = 0,
    String? timezone,
  }) async {
    final location = _locationFor(timezone);
    await _scheduleDaily(
      _dailyWorkoutReminderId,
      hour,
      minute,
      'Time to Move! \u{1F4AA}',
      'Your daily workout reminder. Open NutriTrack to start.',
      location,
      channelId: 'workout_reminders',
      channelName: 'Workout Reminders',
      channelDescription: 'Daily workout reminder notifications',
      payload: AppRoutes.workoutHub,
    );
  }

  Future<void> cancelWorkoutReminder() async {
    await _plugin.cancel(_dailyWorkoutReminderId);
  }

  Future<void> cancelMealReminders() {
    return Future.wait(_mealReminderIds.map(_plugin.cancel));
  }

  Future<void> applySettings(
    UserNotificationSettings settings, {
    String? timezone,
  }) async {
    final location = _locationFor(timezone);
    await Future.wait([
      _applySingleDaily(
        id: _singleMealReminderId,
        preference: settings.meal,
        title: 'NutriTrack India',
        body: 'Time to log your meal.',
        channelId: 'meal_reminders',
        channelName: 'Meal Reminders',
        route: AppRoutes.nutrition,
        location: location,
      ),
      _applySingleDaily(
        id: _waterReminderId,
        preference: settings.water,
        title: 'NutriTrack India',
        body: 'Drink water and update your hydration.',
        channelId: 'water_reminders',
        channelName: 'Water Reminders',
        route: AppRoutes.dashboard,
        location: location,
      ),
      _applyWeeklyWorkout(
        preference: settings.workout,
        location: location,
      ),
      _applySingleDaily(
        id: _weighInReminderId,
        preference: settings.weighIn,
        title: 'NutriTrack India',
        body: 'Quick weigh-in helps keep your goal current.',
        channelId: 'weigh_in_reminders',
        channelName: 'Weigh-in Reminders',
        route: AppRoutes.bmiCalculator,
        location: location,
      ),
      _applySingleDaily(
        id: _streakReminderId,
        preference: settings.streak,
        title: 'NutriTrack India',
        body: 'Keep your healthy streak alive today.',
        channelId: 'streak_reminders',
        channelName: 'Streak Reminders',
        route: AppRoutes.dashboard,
        location: location,
      ),
    ]);
  }

  Future<void> cancelReminderGroup(String group) {
    final ids = switch (group) {
      'meal' => [_singleMealReminderId, ..._mealReminderIds],
      'water' => [_waterReminderId],
      'workout' => _workoutReminderIds,
      'weighIn' => [_weighInReminderId],
      'streak' => [_streakReminderId],
      _ => const <int>[],
    };
    return Future.wait(ids.map(_plugin.cancel));
  }

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
    {
    String channelId = 'meal_reminders',
    String channelName = 'Meal Reminders',
    String channelDescription = 'Daily NutriTrack India meal reminders',
    String payload = AppRoutes.calorieLog,
  }) {
    return _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute, location),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  Future<void> _applySingleDaily({
    required int id,
    required ReminderPreference preference,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    required String route,
    required tz.Location location,
  }) async {
    await _plugin.cancel(id);
    if (!preference.enabled) return;
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(preference.hour, preference.minute, location),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: route,
    );
  }

  Future<void> _applyWeeklyWorkout({
    required ReminderPreference preference,
    required tz.Location location,
  }) async {
    await Future.wait(_workoutReminderIds.map(_plugin.cancel));
    if (!preference.enabled) return;
    final days = preference.days.isEmpty ? const [1, 3, 5] : preference.days;
    await Future.wait(days.map((day) {
      return _plugin.zonedSchedule(
        _workoutReminderBaseId + day,
        'NutriTrack India',
        'Your planned workout is waiting.',
        _nextInstanceOfWeekday(
          day,
          preference.hour,
          preference.minute,
          location,
        ),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'workout_reminders',
            'Workout Reminders',
            channelDescription: 'Workout reminder notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: AppRoutes.workouts,
      );
    }));
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

  tz.TZDateTime _nextInstanceOfWeekday(
    int weekday,
    int hour,
    int minute,
    tz.Location location,
  ) {
    var scheduled = _nextInstanceOfTime(hour, minute, location);
    while (scheduled.weekday != weekday) {
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

  static const _mealReminderIds = [100, 101, 102];
  static const _dailyWorkoutReminderId = 3;
  static const _singleMealReminderId = 110;
  static const _waterReminderId = 200;
  static const _workoutReminderBaseId = 300;
  static const _workoutReminderIds = [301, 302, 303, 304, 305, 306, 307];
  static const _weighInReminderId = 400;
  static const _streakReminderId = 500;
}
