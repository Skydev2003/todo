import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // สมัครสมาชิก (Sign Up)
  Future<AuthResponse> signUp(String email, String password) async {
    return await _supabase.auth.signUp(email: email, password: password);
  }

  // เข้าสู่ระบบ (Login)
  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  // ออกจากระบบ (Logout)
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // ดึงข้อมูล User ปัจจุบัน
  User? get currentUser => _supabase.auth.currentUser;

  // Stream สำหรับคอยฟังสถานะ (Login/Logout)
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
