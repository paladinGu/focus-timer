import 'package:flutter/material.dart';
import 'package:focus_timer/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  List<Task> get pendingTasks =>
      _tasks.where((task) => !task.isCompleted).toList();
  List<Task> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList();
  bool get isLoading => _isLoading;

  TaskProvider() {
    _loadTasks();
  }

  // 从本地加载任务
  Future<void> _loadTasks() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList('tasks');
    
    if (tasksJson != null) {
      _tasks = tasksJson
          .map((json) => Task.fromJson({'id': json.split('|||')[0], ...}))
          .where((task) {
            try {
              // 简单解析，如果失败则跳过
              final parts = json.split('|||');
              if (parts.length >= 2) {
                return true;
              }
              return false;
            } catch (e) {
              return false;
            }
          })
          .toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  // 保存任务到本地
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = _tasks.map((task) => task.title).toList();
    await prefs.setStringList('tasks', tasksJson);
  }

  // 添加任务
  void addTask(String title, {String? description, int totalPomodoros = 1}) {
    final task = Task(
      title: title,
      description: description,
      totalPomodoros: totalPomodoros,
    );
    _tasks.insert(0, task);
    _saveTasks();
    notifyListeners();
  }

  // 更新任务
  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      _saveTasks();
      notifyListeners();
    }
  }

  // 删除任务
  void deleteTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
    _saveTasks();
    notifyListeners();
  }

  // 切换任务完成状态
  void toggleTaskCompletion(String taskId) {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
        completedAt: !_tasks[index].isCompleted ? DateTime.now() : null,
      );
      _saveTasks();
      notifyListeners();
    }
  }

  // 增加已完成番茄钟数
  void incrementCompletedPomodoros(String taskId) {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        completedPomodoros: _tasks[index].completedPomodoros + 1,
      );
      
      // 如果全部完成，标记为完成
      if (_tasks[index].completedPomodoros >= _tasks[index].totalPomodoros) {
        _tasks[index] = _tasks[index].copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
        );
      }
      
      _saveTasks();
      notifyListeners();
    }
  }

  // 清空已完成任务
  void clearCompletedTasks() {
    _tasks.removeWhere((task) => task.isCompleted);
    _saveTasks();
    notifyListeners();
  }

  // 获取今日任务统计
  int get todayCompletedTasks {
    final today = DateTime.now();
    return _tasks
        .where((task) =>
            task.isCompleted &&
            task.completedAt != null &&
            task.completedAt!.day == today.day)
        .length;
  }

  // 获取今日总番茄钟数
  int get todayTotalPomodoros {
    final today = DateTime.now();
    return _tasks
        .where((task) =>
            task.completedAt != null &&
            task.completedAt!.day == today.day)
        .fold(0, (sum, task) => sum + task.completedPomodoros);
  }
}
