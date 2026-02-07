import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/todos_screen.dart';
import '../screens/calendar_screen.dart'; // เดี๋ยวสร้าง
import '../screens/profile_screen.dart'; // เดี๋ยวสร้าง
import 'main_wrapper.dart'; // เดี๋ยวสร้าง
import '../services/fcm_service.dart'; // สำหรับ save token

final goRouterProvider = Provider<GoRouter>((ref) {
  // ดักฟังสถานะ Auth เพื่อ Refresh Route
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/tasks',
    refreshListenable: GoRouterRefreshStream(ref.read(authServiceProvider).authStateChanges),
    debugLogDiagnostics: true,
    
    // Logic การเปลี่ยนหน้าอัตโนมัติ (Guard)
    redirect: (context, state) {
      final isLoggedIn = authState.asData?.value != null;
      final isLoggingIn = state.uri.toString() == '/login';

      if (!isLoggedIn && !isLoggingIn) {
        return '/login'; // ถ้ายังไม่ Login ให้ไปหน้า Login
      }

      if (isLoggedIn && isLoggingIn) {
        return '/tasks'; // ถ้า Login แล้วพยายามเข้าหน้า Login ให้ดีดไปหน้าแรก
      }

      // ถ้า Login แล้ว ให้บันทึก Token (ทำตรงนี้สะดวกดี)
      if (isLoggedIn && authState.asData?.value != null) {
         saveDeviceToken(authState.asData!.value!.id);
      }

      return null; // ปล่อยผ่าน
    },

    routes: [
      // หน้า Login
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // โครงสร้างหลักที่มี Bottom Bar (StatefulShellRoute)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(navigationShell: navigationShell);
        },
        branches: [
          // Tab 1: Tasks
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                builder: (context, state) => const TodosScreen(),
              ),
            ],
          ),
          // Tab 2: Calendar
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          // Tab 3: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});


class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}