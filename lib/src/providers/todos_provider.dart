import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todos_model.dart';
import '../services/todos_service.dart';

// 1. Provider สำหรับ Service
final todosServiceProvider = Provider<TodosService>((ref) {
  return TodosService();
});

final todosProvider = StreamNotifierProvider<TodosNotifier, List<TodosModel>>(() {
  return TodosNotifier();
});

// ✅ แก้ไขตรงนี้: extends "StreamNotifier" ธรรมดา (ลบคำว่า AutoDispose ออก)
class TodosNotifier extends StreamNotifier<List<TodosModel>> {
  @override
  Stream<List<TodosModel>> build() {
    // เชื่อมต่อกับ Stream จาก Service
    return ref.read(todosServiceProvider).getTodosStream();
  }

  // ฟังก์ชันเพิ่ม
  Future<void> addTodo(String title, String? description, DateTime? reminderTime) async {
    try {
      final service = ref.read(todosServiceProvider);
      await service.addTodo(title, description, reminderTime);
    } catch (e) {
      rethrow; // ถ้ามี error ให้ส่ง error ต่อไป
    }
  }

  // ฟังก์ชันอัพเดต
  Future<void> updateTodo(int id, String title, String? description, DateTime? reminderTime) async {
    try {
      final service = ref.read(todosServiceProvider);
      await service.updateTodo(id, title, description, reminderTime);
    } catch (e) {
      rethrow; // ถ้ามี error ให้ส่ง error ต่อไป
    }
  }

  // ฟังก์ชันเปลี่ยนสถานะ
  Future<void> toggleStatus(int id, bool isCompleted) async {
    try {
      final service = ref.read(todosServiceProvider);
      await service.toggleTodoStatus(id, isCompleted);
    } catch (e) {
      rethrow; // ถ้ามี error ให้ส่ง error ต่อไป
    }
  }

  // ฟังก์ชันลบ
  Future<void> deleteTodo(int id) async {
    try {
      final service = ref.read(todosServiceProvider);
      await service.deleteTodo(id);
    } catch (e) {
      rethrow; // ถ้ามี error ให้ส่ง error ต่อไป
    }
  }
}
