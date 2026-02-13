import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focus_timer/providers/task_provider.dart';
import 'package:focus_timer/models/task.dart';
import 'package:focus_timer/theme/app_theme.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _selectedPomodoros = 1;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Column(
      children: [
        // Tab切换
        _buildTabs(taskProvider),
        
        // 任务列表
        Expanded(
          child: _buildTaskList(taskProvider),
        ),
        
        // 添加任务按钮
        _buildAddButton(context),
      ],
    );
  }

  Widget _buildTabs(TaskProvider taskProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {}),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '待办',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {}),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '已完成 (${taskProvider.completedTasks.length})',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(TaskProvider taskProvider) {
    final pendingTasks = taskProvider.pendingTasks;
    final completedTasks = taskProvider.completedTasks;

    if (pendingTasks.isEmpty && completedTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              '暂无任务',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '添加第一个任务开始专注吧',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pendingTasks.isNotEmpty) ...[
            const Text(
              '待办任务',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            ...pendingTasks.map((task) => _buildTaskCard(context, task, false)),
            const SizedBox(height: 24),
          ],
          if (completedTasks.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '已完成',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                TextButton(
                  onPressed: taskProvider.clearCompletedTasks,
                  child: const Text('清空已完成'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...completedTasks.map((task) => _buildTaskCard(context, task, true)),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppTheme.surfaceColor.withOpacity(0.5)
            : AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // 复选框
          GestureDetector(
            onTap: () => taskProvider.toggleTaskCompletion(task.id),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCompleted ? AppTheme.success : Colors.transparent,
                border: Border.all(
                  color: isCompleted ? AppTheme.success : AppTheme.textSecondary,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          
          // 任务信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    color: isCompleted
                        ? AppTheme.textSecondary
                        : AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                if (task.description != null &&
                    task.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.description!,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                // 番茄钟进度
                Row(
                  children: List.generate(
                    task.totalPomodoros,
                    (index) => Container(
                      width: 20,
                      height: 6,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: index < task.completedPomodoros
                            ? AppTheme.primaryColor
                            : AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 操作按钮
          if (!isCompleted)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  taskProvider.deleteTask(task.id);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('删除'),
                ),
              ],
              icon: const Icon(
                Icons.more_vert,
                color: AppTheme.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ElevatedButton.icon(
        onPressed: () => _showAddTaskDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('添加任务'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: const Text(
            '添加任务',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '任务标题',
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '任务描述（可选）',
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                ),
              ),
              const SizedBox(height: 16),
              const Text('预计番茄钟数'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(
                    5,
                    (index) => GestureDetector(
                      onTap: () => setState(() => _selectedPomodoros = index + 1),
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: _selectedPomodoros == index + 1
                              ? AppTheme.primaryColor
                              : AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: _selectedPomodoros == index + 1
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  context.read<TaskProvider>().addTask(
                        _titleController.text,
                        description: _descriptionController.text,
                        totalPomodoros: _selectedPomodoros,
                      );
                  _titleController.clear();
                  _descriptionController.clear();
                  _selectedPomodoros = 1;
                  Navigator.pop(context);
                }
              },
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
  }
}
