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
      isCompleted: json['is_completed'] ?? false,
      reminderTime: json['reminder_time'] != null
          ? DateTime.parse(json['reminder_time'])
                .toLocal() // แนะนำใส่ .toLocal() ด้วยเพื่อให้เวลาตรง
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  TodosModel copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? reminderTime,
    DateTime? createdAt,
  }) {
    return TodosModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderTime: reminderTime ?? this.reminderTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}