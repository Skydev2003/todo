import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> saveDeviceToken(String userId) async {
  // 1. ขอ Token จาก Firebase
  String? token = await FirebaseMessaging.instance.getToken();

  if (token != null) {
    final supabase = Supabase.instance.client;

    // 2. บันทึกลงตาราง user_fcm_tokens (ใช้ upsert เพื่อกันข้อมูลซ้ำ)
    await supabase.from('user_fcm_tokens').upsert(
      {
        'user_id': userId,
        'fcm_token': token,
        'device_type': Platform.isAndroid ? 'android' : 'ios',
        'created_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'user_id, fcm_token', // ถ้ามี token นี้ของ user นี้แล้ว ให้ทับ (update)
    );
  }
}
