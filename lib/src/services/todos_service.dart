import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/todos_model.dart';

class TodosService {
  final supabase = Supabase.instance.client;

  Future<List<TodosModel>> getTodos() async {
    final response = await supabase
        .from('todos')
        .select()
        .order('createdAt', ascending: false);
    
    return (response as List).map((json) => TodosModel.fromJson(json)).toList();
  }

  Future<void> addTodo(String title, String? description, DateTime? reminderTime) async {
    await supabase.from('todos').insert({
      'title': title,
      'description': description,
      'reminderTime': reminderTime?.toIso8601String(),
      'isCompleted': false,
    });
  }

  Future<void> toggleTodoStatus(int id, bool isCompleted) async {
    await supabase
        .from('todos')
        .update({'isCompleted': isCompleted})
        .eq('id', id);
  }

  Future<void> deleteTodo(int id) async {
    await supabase.from('todos').delete().eq('id', id);
  }

}