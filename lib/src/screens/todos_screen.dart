import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/todos_provider.dart';
import '../widget/buttom_todo.dart';

class TodosScreen extends ConsumerStatefulWidget {
  const TodosScreen({super.key});

  @override
  ConsumerState<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends ConsumerState<TodosScreen> {
  @override
  Widget build(BuildContext context) {
    final todostate = ref.watch(todosProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: const Text('Todo', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.invalidate(todosProvider);
              ref.read(authServiceProvider).signOut();
            },
          ),
        ],
      ),
      body: todostate.when(
        data: (item) => ListView.builder(
          itemCount: item.length,
          itemBuilder: (context, index) {
            final todo = item[index];
            return Column(
              children: [
                ListTile(
                  leading:Switch(
                    value: todo.isCompleted,
                    onChanged: (value) {
                      ref.read(todosProvider.notifier).toggleStatus(todo.id, value);
                    },
                  ) ,
                  title: Text(todo.title),
                  subtitle: Text(todo.description ?? ''),
                  trailing:Icon(Icons.alarm),
                ),
              ],
            );
          },
        ),
        error: (context, error) => Text('Error: ${error.toString()}'),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
     floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        onPressed: () {
          // เรียกใช้ Bottom Sheet ที่สร้างขึ้น
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // ให้ขยายเต็มจอเวลาคีย์บอร์ดขึ้น
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            builder: (context) => const AddTodoBottomSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
