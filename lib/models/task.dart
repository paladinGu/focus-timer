import 'package:uuid/uuid.dart';

class Task {
  final String id;
  String title;
  String? description;
  bool isCompleted;
  int totalPomodoros;
  int completedPomodoros;
  DateTime createdAt;
  DateTime? completedAt;

  Task({
    String? id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.totalPomodoros = 1,
    this.completedPomodoros = 0,
    DateTime? createdAt,
    this.completedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'totalPomodoros': totalPomodoros,
      'completedPomodoros': completedPomodoros,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['isCompleted'],
      totalPomodoros: json['totalPomodoros'],
      completedPomodoros: json['completedPomodoros'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    int? totalPomodoros,
    int? completedPomodoros,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      totalPomodoros: totalPomodoros ?? this.totalPomodoros,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
