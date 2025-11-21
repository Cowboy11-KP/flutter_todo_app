import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  /// Khởi tạo notification và timezone
  static Future<void> init() async {
    try {
      // Khởi tạo timezone
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

      // Android settings
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      // iOS settings
      const ios = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      const settings = InitializationSettings(android: android, iOS: ios);

      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: (payload) {
          if (kDebugMode) {
            print('Notification clicked: $payload');
          }
        },
      );

      // iOS xin quyền
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      debugPrint('✅ NotificationService initialized');
    } catch (e) {
      debugPrint('❌ NotificationService init error: $e');
    }
  }

  /// Hiện notification ngay lập tức
  static Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'todo_channel',
        'Todo Notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        ticker: 'ticker',
      );

      const iosDetails = DarwinNotificationDetails();
      const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

      await _notifications.show(0, title, body, details, payload: 'todo_payload');
      debugPrint('✅ Instant notification sent: $title');
    } catch (e) {
      debugPrint('❌ showInstantNotification error: $e');
    }
  }

  /// Lên lịch notification
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

      if (tzTime.isBefore(tz.TZDateTime.now(tz.local))) {
        debugPrint('❌ Cannot schedule notification in the past: $scheduledTime');
        return;
      }

      final androidDetails = AndroidNotificationDetails(
        'todo_channel',
        'Todo Notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        ticker: 'ticker',
      );

      final iosDetails = DarwinNotificationDetails();
      final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'todo_payload',
      );

      debugPrint('✅ Scheduled notification: $title at $scheduledTime');
    } catch (e) {
      debugPrint('❌ scheduleNotification error: $e');
    }
  }

  /// Hủy 1 notification
  static Future<void> cancel(int id) async {
    try {
      await _notifications.cancel(id);
      debugPrint('✅ Notification canceled: $id');
    } catch (e) {
      debugPrint('❌ cancel notification error: $e');
    }
  }

  /// Hủy tất cả notification
  static Future<void> cancelAll() async {
    try {
      await _notifications.cancelAll();
      debugPrint('✅ All notifications canceled');
    } catch (e) {
      debugPrint('❌ cancelAll error: $e');
    }
  }
}
