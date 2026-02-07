import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_messaging/firebase_messaging.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // ✅ แก้ไข 1: ใส่ settings: (ตาม v20.0.0)
    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          print('User tapped notification with payload: ${response.payload}');
        }
      },
    );

    // ขอ Permission Android 13+
    if (Platform.isAndroid) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  static Future<void> showNotification({required String title, required String body, String? payload}) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'your_channel_id',
      'General Notifications',
      channelDescription: 'Notification channel for general alerts',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    int id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // ✅ แก้ไข 2: ใส่ชื่อ parameter ครบทุกตัว
    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduleDate = tz.TZDateTime.from(scheduledTime, tz.local);

    if (scheduleDate.isBefore(now)) {
      return;
    }

    // ✅ แก้ไข 3: อิงตาม v20.0.0
    // - ตัด uiLocalNotificationDateInterpretation ออก (ถ้า Error ค่อยใส่กลับเป็น optional)
    // - เพิ่ม androidScheduleMode
    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduleDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'schedule_channel_id',
          'Scheduled Notifications',
          channelDescription: 'Channel for scheduled reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      // สำคัญ: ตามตัวอย่าง v20 ต้องใส่บรรทัดนี้
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      // // หมายเหตุ: ถ้ายัง Error เรื่อง uiLocal... ให้ uncomment บรรทัดล่างนี้
      // uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,

      payload: payload,
    );

    print("✅ ตั้งปลุกสำเร็จ ID: $id เวลา: $scheduledTime");
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  static Future<void> showFirebaseNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await showNotification(
        title: notification.title ?? 'No Title',
        body: notification.body ?? 'No Body',
        payload: message.data.toString(),
      );
    }
  }
}
