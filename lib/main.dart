import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'src/routes/app_router.dart';
import 'src/services/local_notification_service.dart';
import 'supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  await LocalNotificationService.init();

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    LocalNotificationService.showFirebaseNotification(message);
  });

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ เรียกใช้ goRouterProvider
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      // ✅ เปลี่ยนเป็น .router
      debugShowCheckedModeBanner: false,
      title: 'My Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white, // พื้นหลังขาวตามดีไซน์
      ),
      // ✅ เชื่อม Config ของ GoRouter
      routerConfig: goRouter,
    );
  }
}
