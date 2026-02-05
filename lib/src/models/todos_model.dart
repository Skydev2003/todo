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
      reminderTime: json['reminderTime'] != null
          ? DateTime.parse(json['reminderTime'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}