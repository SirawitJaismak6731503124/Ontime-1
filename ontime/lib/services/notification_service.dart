import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/routine.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> scheduleRoutine(Routine routine) async {
    await cancelRoutine(routine.id);

    if (!routine.isActive) return;

    for (final day in routine.days) {
      final notifId = _notifId(routine.id, day);
      await _scheduleWeekly(
        id: notifId,
        title: routine.title,
        body: 'Time for your routine — ${routine.formattedTime}',
        weekday: day,
        hour: routine.hour,
        minute: routine.minute,
      );
    }
  }

  Future<void> cancelRoutine(String routineId) async {
    for (int day = 1; day <= 7; day++) {
      await _plugin.cancel(_notifId(routineId, day));
    }
  }

  int _notifId(String routineId, int day) {
    // Derive a stable int from the routineId + day
    final hash = routineId.hashCode.abs();
    return (hash % 100000) * 10 + day;
  }

  Future<void> _scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = _nextWeekday(now, weekday, hour, minute);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'ontime_routines',
          'Routine Reminders',
          channelDescription: 'Notifications for your daily routines',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  tz.TZDateTime _nextWeekday(
      tz.TZDateTime from, int weekday, int hour, int minute) {
    // weekday: 1=Mon ... 7=Sun (DateTime uses 1=Mon ... 7=Sun too)
    var candidate = tz.TZDateTime(
        tz.local, from.year, from.month, from.day, hour, minute);

    // Advance until we hit the right weekday and it's in the future
    int attempts = 0;
    while (candidate.weekday != weekday || candidate.isBefore(from)) {
      candidate = candidate.add(const Duration(days: 1));
      attempts++;
      if (attempts > 8) break; // safety
    }
    return candidate;
  }
}
