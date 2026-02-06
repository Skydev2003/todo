import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo/src/screens/todos_screen.dart';
import 'firebase_options.dart';
import 'src/providers/auth_provider.dart';
import 'src/providers/fcm_provider.dart';
import 'src/screens/login_screen.dart';
import 'supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 3. เริ่มต้น Firebase (เพิ่มตรงนี้!)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(const ProviderScope(child: MyApp()));
}

// main.dart

class MyApp extends ConsumerWidget { // เปลี่ยนเป็น ConsumerWidget
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ดักฟังสถานะ Auth
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
      ),
      home: authState.when(
        data: (user) {
          // ถ้า user ไม่เป็น null แสดงว่า Login แล้ว -> ไปหน้า TodosScreen
          if (user != null) {
            // เมื่อ Login ค้างอยู่ ให้ส่ง Token ขึ้น Server ทันที
            saveDeviceToken(user.id);
            return const TodosScreen(); 
          }
          // ถ้าเป็น null -> ไปหน้า LoginScreen
          return const LoginScreen();
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      ),
    );
  }
}

