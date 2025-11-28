import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/data/local/hive_service.dart';
import 'package:frontend/data/models/task_model.dart';
import 'package:frontend/repository/task/task_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

// Hàm này chạy độc lập khi App đang đóng hoặc chạy ngầm
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {

  if (notificationResponse.actionId == 'mark_done') {

    final String? taskId = notificationResponse.payload;
    if (taskId != null) {
      try {
        // khởi tạo hive cho background
        await Hive.initFlutter();

        if (!Hive.isAdapterRegistered(0)) { 
          Hive.registerAdapter(TaskModelAdapter()); 
        }

        final localService = LocalTaskService(); 
        final repository = TaskRepository(local: localService);

        await repository.updateIsDone(taskId);

        print('✅ Background: Đã update xong task $taskId');

      } catch (e){
        print('❌ Background Error: $e');
      }
    }
  }
}

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
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
      );

      const settings = InitializationSettings(android: android, iOS: ios);

      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: (payload) {
          if (kDebugMode) {
            print('Notification clicked: $payload');
          }
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );
      
      // iOS xin quyền
      final iosImplementation = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosImplementation != null) {
        await iosImplementation.requestPermissions(
          alert: true, 
          badge: true, 
          sound: true,
        );
      }

      // Android xin quyền 
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
      }

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
        //action button
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'mark_done',
            'Done',
            showsUserInterface: false,
            cancelNotification: true,
          ),
          AndroidNotificationAction(
            'Snooze',
            'Snooze',
            showsUserInterface: false,
            cancelNotification: true,
          ),
        ],
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
    required String taskId
  }) async {
    try {
      final tzTime = tz.TZDateTime(
        tz.local,
        scheduledTime.year,
        scheduledTime.month,
        scheduledTime.day,
        scheduledTime.hour,
        scheduledTime.minute,
      );

      debugPrint('Gốc: $scheduledTime');
      debugPrint('Sau khi ép Timezone: $tzTime');

      final now = tz.TZDateTime.now(tz.local);
      debugPrint('🕒 Giờ hiện tại của App (Timezone): $now');
      debugPrint('🎯 Giờ bạn muốn hẹn: $scheduledTime');

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
        //action button
        actions: <AndroidNotificationAction>[
          const AndroidNotificationAction(
            'mark_done',
            'Done',
            showsUserInterface: false,
            cancelNotification: true,
          ),
          const AndroidNotificationAction(
            'Snooze',
            'Done',
            showsUserInterface: false,
            cancelNotification: true,
          ),
        ],
      );

      final iosDetails = DarwinNotificationDetails();
      final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzTime,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: taskId,
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
