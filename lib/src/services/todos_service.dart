import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/todos_model.dart';

class TodosService {
  final supabase = Supabase.instance.client;

  Future<List<TodosModel>> getTodos() async {
    final response = await supabase
        .from('todos')
        .select()
        .order('created_at', ascending: false); 

    return (response as List).map((json) => TodosModel.fromJson(json)).toList();
  }

  Future<void> addTodo(String title, String? description, DateTime? reminderTime) async {
    // ต้องดึง User ID ปัจจุบันออกมา เพื่อบอกว่าใครเป็นคนสร้าง
    final userId = supabase.auth.currentUser!.id;

    await supabase.from('todos').insert({
      'user_id': userId,
      'title': title,
      'description': description,
      'reminder_time': reminderTime?.toIso8601String(),
      'is_completed': false,
    });
  }

  Future<void> toggleTodoStatus(int id, bool isCompleted) async {
    await supabase
        .from('todos')
        .update({'is_completed': isCompleted}) 
        .eq('id', id);
  }

  Future<void> updateTodo(int id, String title, String? description, DateTime? reminderTime) async {
    await supabase
        .from('todos')
        .update({
          'title': title,
          'description': description,
          'reminder_time': reminderTime?.toIso8601String(),
          // ไม่ต้องส่ง is_completed หรือ user_id เพราะเราไม่ได้แก้ส่วนนั้น
        })
        .eq('id', id);
  }

  Future<void> deleteTodo(int id) async {
    await supabase.from('todos').delete().eq('id', id);
  }
}
