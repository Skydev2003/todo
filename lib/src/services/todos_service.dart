import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/todos_model.dart';

class TodosService {
  final supabase = Supabase.instance.client;

  //  ต้องใช้ .stream(primaryKey: ['id']) เท่านั้น
  Stream<List<TodosModel>> getTodosStream() {
    return supabase
        .from('todos')
        .stream(primaryKey: ['id']) 
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => TodosModel.fromJson(json)).toList());
  }

  Future<void> addTodo(String title, String? description, DateTime? reminderTime) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('กรุณาเข้าสู่ระบบ');

    await supabase.from('todos').insert({
      'user_id': user.id,
      'title': title,
      'description': description,
      'reminder_time': reminderTime?.toUtc().toIso8601String(),
      'is_completed': false,
    });
  }

  // ... (updateTodo, toggleTodoStatus, deleteTodo ก็เหมือนเดิม) ...
  Future<void> toggleTodoStatus(int id, bool isCompleted) async {
    await supabase.from('todos').update({'is_completed': isCompleted}).eq('id', id);
  }

  Future<void> deleteTodo(int id) async {
    await supabase.from('todos').delete().eq('id', id);
  }

  Future<void> updateTodo(int id, String title, String? description, DateTime? reminderTime) async {
    await supabase
        .from('todos')
        .update({'title': title, 'description': description, 'reminder_time': reminderTime?.toUtc().toIso8601String()})
        .eq('id', id);
  }
}
