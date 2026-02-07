import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/todos_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    // ดึงข้อมูล User ปัจจุบัน
    final authState = ref.watch(authStateProvider);
    final userEmail = authState.asData?.value?.email ?? 'Guest';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // ✅ ใช้ Column เป็นโครงหลัก
        child: Column(
          children: [
            // -------------------------------------------------------
            // 🟢 ส่วนที่ 1: เนื้อหาด้านบน (ยืดเต็มพื้นที่ด้วย Expanded)
            // -------------------------------------------------------
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header Title
                      const Text(
                        "My Profile",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 40),

                      // Avatar
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.pinkAccent.withOpacity(0.2), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[100],
                          child: const Icon(Icons.person, size: 50, color: Colors.pinkAccent),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Email Info
                      Text(
                        userEmail,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Text("Member since 2024", style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                    ],
                  ),
                ),
              ),
            ),

            // -------------------------------------------------------
            // 🔴 ส่วนที่ 2: ปุ่ม Logout (ติดขอบล่าง)
            // -------------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), // เว้นระยะขอบล่าง 24
              child: _buildLogoutButton(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget: ปุ่ม Logout
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          // 1. ล้างข้อมูล Todo
          ref.invalidate(todosProvider);
          // 2. สั่ง Logout
          await ref.read(authServiceProvider).signOut();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[50],
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text(
              "Log Out",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
