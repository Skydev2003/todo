import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

// 1. Provider สำหรับเรียกใช้ Function (Login, Register, Logout)
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// 2. Provider สำหรับเช็คสถานะ User (Login อยู่หรือเปล่า?)
// คืนค่าเป็น User? (ถ้ามีค่า = Login, ถ้า null = ยังไม่ Login)
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges.map((event) => event.session?.user);
});
