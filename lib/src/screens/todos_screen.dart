import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todos_provider.dart';
import '../widget/buttom_todo.dart';
import '../models/todos_model.dart'; // Import Model เพื่อใช้ Type

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. ส่งข้อมูลไปยัง Header (คำนวณ Progress)
            todostate.when(
              data: (items) => _buildHeaderSection(items), // ✅ ส่งรายการไปคำนวณ
              loading: () => _buildHeaderSection([]), // โหลดอยู่ส่งค่าว่าง
              error: (_, __) => _buildHeaderSection([]),
            ),

            // 2. Task List Section
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Today's Tasks", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {},
                          child: const Text("See All", style: TextStyle(color: Colors.pinkAccent)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // List
                    Expanded(
                      child: todostate.when(
                        data: (items) {
                          if (items.isEmpty) return const Center(child: Text("No tasks yet!"));
                          return ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (c, i) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final todo = items[index];
                              return _buildTodoItem(todo); // ✅ แยก Widget เพื่อความสะอาด
                            },
                          );
                        },
                        error: (err, stack) => Center(child: Text('Error: $err')),
                        loading: () => const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        shape: const CircleBorder(),
        onPressed: () {
          // เปิด BottomSheet แบบ "เพิ่มงานใหม่" (ไม่มีข้อมูลเก่า)
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            builder: (context) => const AddTodoBottomSheet(),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  // ✅ Widget สำหรับแต่ละรายการงาน (มีการ์ด, Checkbox, 3-dot menu)
  Widget _buildTodoItem(TodosModel todo) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Transform.scale(
          scale: 1.2,
          child: Checkbox(
            activeColor: Colors.pinkAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            value: todo.isCompleted,
            onChanged: (value) {
    // ✅ ต้องส่ง 3 ค่า: (id, ค่าใหม่, ตัว object เดิม)
    ref.read(todosProvider.notifier).toggleStatus(todo.id, value ?? false, todo);
  },
          ),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: todo.reminderTime == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.pinkAccent),
                    const SizedBox(width: 4),
                    Text(
                      "${todo.reminderTime!.hour.toString().padLeft(2, '0')}:${todo.reminderTime!.minute.toString().padLeft(2, '0')}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
        // ✅ เปลี่ยนจาก IconButton เป็น PopupMenuButton
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          onSelected: (value) {
            if (value == 'edit') {
              // เปิด BottomSheet แบบ "แก้ไข" (ส่ง todo ไปด้วย)
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                builder: (context) => AddTodoBottomSheet(todoToEdit: todo), // ✅ ส่งข้อมูลไปแก้ไข
              );
            } else if (value == 'delete') {
              ref.read(todosProvider.notifier).deleteTodo(todo.id);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'edit',
              child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 10), Text('แก้ไข')]),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 10),
                  Text('ลบ', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Header ที่คำนวณ Progress จริง
  Widget _buildHeaderSection(List<TodosModel> items) {
    // 🧮 คำนวณเปอร์เซ็นต์
    int total = items.length;
    int completed = items.where((t) => t.isCompleted).toList().length;
    double percent = total == 0 ? 0 : completed / total;
    int percentInt = (percent * 100).toInt();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          // ... (ส่วน Hello User เหมือนเดิม) ...
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Hello, User!",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pinkAccent),
                  ),
                  Text("Let's be productive today.", style: TextStyle(color: Colors.grey)),
                ],
              ),
              const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.pinkAccent,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // การ์ด Progress สีชมพู
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.pinkAccent, Color(0xFFF48FB1)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.pinkAccent.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Daily Progress",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: percent, // ✅ ค่าจริง
                        backgroundColor: Colors.white30,
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      const SizedBox(height: 8),
                      // ✅ ข้อความจริง
                      Text(
                        "$completed of $total tasks completed",
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                  // ✅ ตัวเลขจริง
                  child: Text(
                    "$percentInt%",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
