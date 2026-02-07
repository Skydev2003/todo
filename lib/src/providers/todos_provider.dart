import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todos_model.dart';
import '../services/todos_service.dart';
import '../services/local_notification_service.dart'; // อย่าลืม import

// 1. Service Provider
final todosServiceProvider = Provider<TodosService>((ref) {
  return TodosService();
});

// 2. Main Provider: 🔴 เอา .autoDispose ออก เพื่อใช้ StreamNotifier ธรรมดา
final todosProvider = StreamNotifierProvider<TodosNotifier, List<TodosModel>>(TodosNotifier.new);

// 3. Class Notifier: ✅ extends StreamNotifier ธรรมดา (เข้าคู่กันแล้ว ไม่แดงแน่นอน)
class TodosNotifier extends StreamNotifier<List<TodosModel>> {
  @override
  Stream<List<TodosModel>> build() {
    // ref.read ใช้ได้ปกติ เพราะอยู่ใน StreamNotifier
    return ref.read(todosServiceProvider).getTodosStream();
  }

  // --- ฟังก์ชัน Action ต่างๆ ---

  Future<void> addTodo(String title, String? description, DateTime? reminderTime) async {
    try {
      final service = ref.read(todosServiceProvider);
      await service.addTodo(title, description, reminderTime);
      // Supabase จะยิง Stream กลับมาเอง UI จะอัปเดตอัตโนมัติ
    } catch (e) {
      print("Add Error: $e");
    }
  }

  Future<void> updateTodo(int id, String title, String? description, DateTime? reminderTime) async {
    try {
      final service = ref.read(todosServiceProvider);
      await service.updateTodo(id, title, description, reminderTime);

      // ✅ Logic: จัดการแจ้งเตือน (ยกเลิกอันเก่า -> ตั้งอันใหม่)
      await LocalNotificationService.cancelNotification(id);

      if (reminderTime != null && reminderTime.isAfter(DateTime.now())) {
        await LocalNotificationService.scheduleNotification(
          id: id,
          title: "⏰ แก้ไข: $title",
          body: description ?? "อย่าลืมทำรายการนี้นะ!",
          scheduledTime: reminderTime,
        );
      }
    } catch (e) {
      print("Update Error: $e");
    }
  }

 Future<void> toggleStatus(int id, bool isCompleted, TodosModel todo) async {
    try {
      // 1. ✅ Optimistic Update: สั่งแก้หน้าจอทันที (ไม่ต้องรอ Server)
      state = state.whenData((todos) {
        return todos.map((t) {
          if (t.id == id) {
            return t.copyWith(isCompleted: isCompleted); // ใช้ copyWith เปลี่ยนค่า
          }
          return t;
        }).toList();
      });

      // 2. ส่งไปแก้ใน Database (ทำเบื้องหลัง)
      final service = ref.read(todosServiceProvider);
      await service.toggleTodoStatus(id, isCompleted);

      // 3. จัดการ Notification (เหมือนเดิม)
      if (isCompleted) {
        print("✅ งานเสร็จแล้ว: ยกเลิกแจ้งเตือน ID $id");
        await LocalNotificationService.cancelNotification(id);
      } else {
        if (todo.reminderTime != null && todo.reminderTime!.isAfter(DateTime.now())) {
          print("🔄 งานยังไม่เสร็จ: ตั้งแจ้งเตือนใหม่ ID $id");
          await LocalNotificationService.scheduleNotification(
            id: id,
            title: "⏰ เตือนความจำ: ${todo.title}",
            body: todo.description ?? "อย่าลืมทำนะ",
            scheduledTime: todo.reminderTime!,
          );
        }
      }
    } catch (e) {
      print("Toggle Error: $e");
      // ถ้า Error อาจจะสั่งให้ ref.invalidateSelf() เพื่อโหลดข้อมูลจริงกลับมา
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      // ✅ ลบแจ้งเตือนก่อนลบงาน
      await LocalNotificationService.cancelNotification(id);

      final service = ref.read(todosServiceProvider);
      await service.deleteTodo(id);
    } catch (e) {
      print("Delete Error: $e");
    }
  }
}
