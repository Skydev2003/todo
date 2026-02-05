import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todos_model.dart';
import '../services/todos_service.dart';

// 1. Provider สำหรับ Service (เพื่อให้เรียกใช้ได้ทั่วแอป และง่ายต่อการแก้ภายหลัง)
final todosServiceProvider = Provider<TodosService>((ref) {
  return TodosService();
});

// 2. Main Provider: จัดการ State ของ Todo List (Load, Add, Edit, Delete)
final todosProvider = AsyncNotifierProvider<TodosNotifier, List<TodosModel>>(() {
  return TodosNotifier();
});

class TodosNotifier extends AsyncNotifier<List<TodosModel>> {

  @override
  Future<List<TodosModel>> build() async {
    return _fetchTodos();
  }

  Future<List<TodosModel>> _fetchTodos() async {
    final service = ref.read(todosServiceProvider);
    return service.getTodos();
  }

  // ฟังชันก์เพิ่ม
  Future<void> addTodo(String title, String? description, DateTime? reminderTime) async {
    // 1. เซ็ตสถานะเป็น Loading (เพื่อให้ UI แสดง CircularProgressIndicator ถ้าต้องการ)
    state = const AsyncValue.loading();

    try {
      // 2. ยิงขึ้น Server
      final service = ref.read(todosServiceProvider);
      await service.addTodo(title, description, reminderTime);

      // 3. สั่งให้โหลดข้อมูลใหม่ทั้งหมดจาก Server (เพื่อให้ได้ ID และข้อมูลล่าสุดชัวร์ๆ)
      ref.invalidateSelf();
      await future; // รอจนกว่าจะโหลดเสร็จ
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  // ฟังก์ชันอัพเดต
  Future<void> updateTodo(int id, String title, String? description, DateTime? reminderTime) async {
    final service = ref.read(todosServiceProvider);

    // จำค่าเดิมไว้ก่อน เผื่อต้อง Rollback
    final previousState = state;

    // 1. Optimistic Update: แก้ข้อมูลในหน้าจอทันที ไม่ต้องรอ Server
    if (state.hasValue) {
      state = AsyncValue.data([
        for (final todo in state.value!)
          if (todo.id == id)
            // สร้าง Object ใหม่ที่อัปเดตข้อมูลแล้ว (แต่ id, isCompleted, createdAt เหมือนเดิม)
            TodosModel(
              id: todo.id,
              title: title,
              description: description,
              isCompleted: todo.isCompleted,
              reminderTime: reminderTime,
              createdAt: todo.createdAt,
            )
          else
            todo,
      ]);
    }

    try {
      // 2. ส่งข้อมูลไปอัปเดตที่ Database จริง
      await service.updateTodo(id, title, description, reminderTime);
    } catch (e) {
      // 3. ถ้า Error ให้ย้อนกลับค่าเดิม
      state = previousState;
    }
  }
  //ฟังก์ชันเปลี่ยนสถานะ
  Future<void> toggleStatus(int id, bool isCompleted) async {
    final service = ref.read(todosServiceProvider);

    // ** เทคนิค Optimistic Update **
    // คือแก้ที่หน้าจอให้ User เห็นก่อนเลยว่าติ๊กแล้ว (จะได้ไม่รู้สึกหน่วง) แล้วค่อยยิง Server
    final previousState = state; // จำค่าเดิมไว้เผื่อ Server error

    if (state.hasValue) {
      state = AsyncValue.data([
        for (final todo in state.value!)
          if (todo.id == id)
            // สร้าง Object ใหม่ที่แก้ค่า isCompleted แล้ว
            TodosModel(
              id: todo.id,
              title: todo.title,
              description: todo.description,
              isCompleted: isCompleted,
              reminderTime: todo.reminderTime,
              createdAt: todo.createdAt,
            )
          else
            todo,
      ]);
    }

    try {
      // ยิงไปอัปเดตที่ Server
      await service.toggleTodoStatus(id, isCompleted);
    } catch (e) {
      // ถ้าพัง ให้ย้อนค่ากลับเป็นเหมือนเดิม
      state = previousState;
      // (Optional) อาจจะ show SnackBar แจ้งเตือน Error ตรงนี้
    }
  }
  
  // ฟังก์ชันลบ
  Future<void> deleteTodo(int id) async {
    // ใช้เทคนิค Optimistic Update เหมือนกัน (ลบจากจอทันที)
    final previousState = state;

    if (state.hasValue) {
      state = AsyncValue.data(state.value!.where((todo) => todo.id != id).toList());
    }

    try {
      final service = ref.read(todosServiceProvider);
      await service.deleteTodo(id);
    } catch (e) {
      // ถ้าลบไม่สำเร็จที่ Server ก็กู้ข้อมูลกลับมา
      state = previousState;
    }
  }
}
