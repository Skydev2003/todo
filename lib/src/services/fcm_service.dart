import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> saveDeviceToken(String userId) async {
  // 1. ✅ เพิ่มส่วนนี้: ขออนุญาตแจ้งเตือน (สำหรับ Android 13+)
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(alert: true, badge: true, sound: true);

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('🔔 User granted permission');

    // 2. ขอ Token
    String? token = await messaging.getToken();

    if (token != null) {
      print("🔥 FCM Token: $token"); // ปริ้นดูหน่อยว่าได้ Token ไหม
      final supabase = Supabase.instance.client;

      // 3. บันทึกลงตาราง
      await supabase.from('user_fcm_tokens').upsert({
        'user_id': userId,
        'fcm_token': token,
        'device_type': Platform.isAndroid ? 'android' : 'ios',
        'created_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id, fcm_token');
    }
  } else {
    print('🔕 User declined or has not accepted permission');
  }
}
