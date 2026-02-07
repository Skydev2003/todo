import 'package:flutter/cupertino.dart'; // ✅ เพิ่ม import นี้เพื่อใช้ Picker แบบเลื่อน
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todos_provider.dart';
import '../models/todos_model.dart';

class AddTodoBottomSheet extends ConsumerStatefulWidget {
  final TodosModel? todoToEdit;

  const AddTodoBottomSheet({super.key, this.todoToEdit});

  @override
  ConsumerState<AddTodoBottomSheet> createState() => _AddTodoBottomSheetState();
}

class _AddTodoBottomSheetState extends ConsumerState<AddTodoBottomSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    if (widget.todoToEdit != null) {
      _titleController.text = widget.todoToEdit!.title;
      _descController.text = widget.todoToEdit!.description ?? '';
      _selectedDateTime = widget.todoToEdit!.reminderTime;
    }
  }

  // ✅ ฟังก์ชันใหม่: เลือกวัน+เวลา ในหน้าจอเดียว (Scroll ได้เลย)
  void _showDateTimePicker() {
    DateTime tempPickedDate = _selectedDateTime ?? DateTime.now();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (BuildContext builder) {
        return SizedBox(
          height: 300, // ความสูงพอเหมาะสำหรับการเลื่อน
          child: Column(
            children: [
              // หัวข้อ + ปุ่มยืนยัน
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                    ),
                    const Text('Select Date & Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedDateTime = tempPickedDate;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Done',
                        style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 0),
              // ตัวเลือกวันเวลาแบบ Scroll (iOS Style)
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime, // เลือกทั้งวันและเวลา
                  initialDateTime: tempPickedDate,
                  minimumDate: DateTime.now().subtract(const Duration(minutes: 1)),
                  use24hFormat: true, // ใช้รูปแบบ 24 ชม.
                  onDateTimeChanged: (val) {
                    tempPickedDate = val;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    if (widget.todoToEdit == null) {
      ref.read(todosProvider.notifier).addTodo(title, _descController.text.trim(), _selectedDateTime);
    } else {
      ref
          .read(todosProvider.notifier)
          .updateTodo(widget.todoToEdit!.id, title, _descController.text.trim(), _selectedDateTime);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.todoToEdit != null;
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 12, 24, keyboardSpace + 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Text(
                isEditing ? 'Edit Task' : 'New Task',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),
              _buildMinimalTextField(
                controller: _titleController,
                label: 'What needs to be done?',
                icon: Icons.check_circle_outline,
                autoFocus: true,
              ),
              const SizedBox(height: 16),
              _buildMinimalTextField(
                controller: _descController,
                label: 'Add a note...',
                icon: Icons.notes_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // ส่วนที่เรียกใช้ Picker ใหม่
              Row(
                children: [
                  const Text("Reminder", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const Spacer(),
                  InkWell(
                    onTap: _showDateTimePicker, // ✅ เรียกฟังก์ชันใหม่ตรงนี้
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedDateTime != null ? Colors.pinkAccent.withOpacity(0.1) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedDateTime != null ? Colors.pinkAccent : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.alarm,
                            size: 18,
                            color: _selectedDateTime != null ? Colors.pinkAccent : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedDateTime == null
                                ? 'Set date & time'
                                : '${_selectedDateTime!.day}/${_selectedDateTime!.month} • ${_selectedDateTime!.hour.toString().padLeft(2, '0')}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: _selectedDateTime != null ? Colors.pinkAccent : Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_selectedDateTime != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: IconButton(
                        onPressed: () => setState(() => _selectedDateTime = null),
                        icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    shadowColor: Colors.pinkAccent.withOpacity(0.4),
                  ),
                  child: Text(
                    isEditing ? 'Save Changes' : 'Create Task',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool autoFocus = false,
  }) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        autofocus: autoFocus,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.grey[400]),
          hintText: label,
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
