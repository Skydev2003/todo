import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todos_provider.dart';

class AddTodoBottomSheet extends ConsumerStatefulWidget {
  const AddTodoBottomSheet({super.key});

  @override
  ConsumerState<AddTodoBottomSheet> createState() => _AddTodoBottomSheetState();
}

class _AddTodoBottomSheetState extends ConsumerState<AddTodoBottomSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDateTime;

  // ฟังก์ชันเลือกวันและเวลา
  Future<void> _pickDateTime() async {
    final now = DateTime.now();

    // 1. เลือกวันที่
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (pickedDate == null) return;

    // 2. เลือกเวลา
    if (!mounted) return;
    final pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (pickedTime == null) return;

    // 3. รวมวันและเวลาเข้าด้วยกัน
    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  // ฟังก์ชันบันทึกข้อมูล
  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      return; // ต้องใส่หัวข้ออย่างน้อย
    }

    // เรียก Provider เพื่อบันทึก
    ref.read(todosProvider.notifier).addTodo(title, _descController.text.trim(), _selectedDateTime);

    // ปิด Bottom Sheet
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // จัดการเรื่องคีย์บอร์ดบังหน้าจอ (Padding ด้านล่าง)
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardSpace + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'เพิ่มรายการใหม่',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // 1. ช่องกรอกชื่อหัวข้อ
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'ชื่อหัวข้อ (Title)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),

            // 2. ช่องกรอกรายละเอียด
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'รายละเอียด (Description)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3, // ให้พิมพ์ได้หลายบรรทัด
            ),
            const SizedBox(height: 12),

            // 3. ส่วนเลือกเวลาแจ้งเตือน
            Row(
              children: [
                const Icon(Icons.alarm, color: Colors.pinkAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedDateTime == null
                        ? 'ยังไม่ได้ตั้งเวลาแจ้งเตือน'
                        : 'แจ้งเตือน: ${_selectedDateTime.toString().substring(0, 16)}',
                    // (ถ้าอยากให้สวยขึ้นแนะนำใช้ package intl)
                    style: TextStyle(color: _selectedDateTime == null ? Colors.grey : Colors.black),
                  ),
                ),
                TextButton(onPressed: _pickDateTime, child: const Text('ตั้งเวลา')),
              ],
            ),
            const SizedBox(height: 20),

            // 4. ปุ่มบันทึก
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('บันทึก', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
