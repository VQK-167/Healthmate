import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'healthmate_reminders',
    'HealthMate reminders',
    description: 'Nhắc nhở sức khỏe từ HealthMate',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    if (kIsWeb) return;

    tz.initializeTimeZones();
    final timezone = await FlutterTimezone.getLocalTimezone();
    final identifier = timezone.identifier == 'Asia/Saigon'
        ? 'Asia/Ho_Chi_Minh'
        : timezone.identifier;
    tz.setLocalLocation(tz.getLocation(identifier));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channel);
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> scheduleDailyReminder({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'healthmate_reminders',
          'HealthMate reminders',
          channelDescription: 'Nhắc nhở sức khỏe từ HealthMate',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleDefaultReminders() async {
    if (kIsWeb) return;

    await scheduleDailyReminder(
      id: 1,
      hour: 9,
      minute: 0,
      title: 'HealthMate',
      body: 'Đã đến lúc uống nước để duy trì sức khỏe hôm nay.',
    );
    await scheduleDailyReminder(
      id: 2,
      hour: 12,
      minute: 30,
      title: 'HealthMate',
      body: 'Đừng quên ghi lại bữa ăn của bạn nhé.',
    );
    await scheduleDailyReminder(
      id: 3,
      hour: 18,
      minute: 0,
      title: 'HealthMate',
      body: 'Hãy dành thời gian vận động hôm nay.',
    );
  }

  Future<void> cancelAll() => _plugin.cancelAll();
}
