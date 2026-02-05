import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/todos_provider.dart';

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
        title: Center(
          child: const Text('Todos', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(todosProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
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
                  title: Text(todo.title),
                  subtitle: Text(todo.description ?? ''),
                  trailing: Checkbox(
                    value: todo.isCompleted,
                    onChanged: (value) {
                      ref.read(todosProvider.notifier).toggleStatus(todo.id, value ?? false);
                    },
                  ),
                ),
              ],
            );
          },
        ),
        error: (context, error) => Text('Error: ${error.toString()}'),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // เพิ่ม Todo ใหม่ (ตัวอย่าง)
          ref.read(todosProvider.notifier).addTodo('New Todo', 'Description', null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
