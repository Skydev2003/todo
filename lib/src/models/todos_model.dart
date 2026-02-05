class TodosModel {
  final int id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime? reminderTime;
  final DateTime createdAt;

  TodosModel({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.reminderTime,
    required this.createdAt,
  });

  factory TodosModel.fromJson(Map<String, dynamic> json) {
    return TodosModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['isCompleted'] ?? false,
      reminderTime: json['reminder_time'] != null
          ? DateTime.parse(json['reminder_time'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  // เพิ่ม function นี้เพื่อใช้ตอนส่งข้อมูลไป Save/Update ที่ Supabase
  Map<String, dynamic> toJson() {
    return {
      // id ไม่ต้องส่งไปตอน create เพราะ Database จะ gen ให้เอง
      'title': title,
      'description': description,
      'is_completed': isCompleted,
      'reminder_time': reminderTime?.toIso8601String(),
      // created_at ปกติไม่ต้องส่ง ให้ DB จัดการเอง หรือส่งเฉพาะตอนจำเป็น
    };
  }
}