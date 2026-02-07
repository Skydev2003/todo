import 'dart:async';
import 'package:riverpod/riverpod.dart';

import '../models/todos_model.dart';
import '../services/todos_service.dart';

// 1. Provider สำหรับ Service
// (อันนี้ใช้ Provider ธรรมดา ต้องรับ (ref) ถูกแล้ว)
final todosServiceProvider = Provider<TodosService>((ref) {
  return TodosService();
});

// 2. Main Provider (ตัวปัญหา)
// ✅ แก้ไข: ใช้ TodosNotifier.new แทนการเขียน function ยาวๆ เพื่อกันพลาด
final todosProvider = StreamNotifierProvider.autoDispose<TodosNotifier, List<TodosModel>>(TodosNotifier.new);

// 3. Class Notifier
// ✅ แก้ไข: ต้อง extends StreamNotifier (สำหรับ StreamNotifierProvider)
class TodosNotifier extends StreamNotifier<List<TodosModel>> {
  @override
  Stream<List<TodosModel>> build() {
    // ✅ ใน build() สามารถเรียกใช้ ref ได้เลย (Riverpod เตรียมไว้ให้แล้ว)
    return ref.read(todosServiceProvider).getTodosStream();
  }

  // --- ฟังก์ชัน Action ต่างๆ ---

  Future<void> addTodo(String title, String? description, DateTime? reminderTime) async {
    try {
      // ✅ เรียก ref.read ได้เลย
      final service = ref.read(todosServiceProvider);
      await service.addTodo(title, description, reminderTime);
    } catch (e) {
      print("Add Error: $e");
    }
  }

  Future<void> updateTodo(int id, String title, String? description, DateTime? reminderTime) async {
    try {
      final service = ref.read(todosServiceProvider);
      await service.updateTodo(id, title, description, reminderTime);
    } catch (e) {
      print("Update Error: $e");
    }
  }

  Future<void> toggleStatus(int id, bool isCompleted) async {
    try {
      final service = ref.read(todosServiceProvider);
      await service.toggleTodoStatus(id, isCompleted);
    } catch (e) {
      print("Toggle Error: $e");
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      final service = ref.read(todosServiceProvider);
      await service.deleteTodo(id);
    } catch (e) {
      print("Delete Error: $e");
    }
  }
}
