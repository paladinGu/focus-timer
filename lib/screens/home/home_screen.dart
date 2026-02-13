import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focus_timer/providers/timer_provider.dart';
import 'package:focus_timer/providers/task_provider.dart';
import 'package:focus_timer/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 今日统计卡片
          _buildTodayStats(context, taskProvider),
          const SizedBox(height: 20),
          
          // 快速开始
          _buildQuickStart(context),
          const SizedBox(height: 20),
          
          // 待完成任务
          _buildPendingTasks(context, taskProvider),
          const SizedBox(height: 20),
          
          // 成就提示
          _buildAchievementTip(),
        ],
      ),
    );
  }

  Widget _buildTodayStats(BuildContext context, TaskProvider taskProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            '今日专注',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${taskProvider.todayTotalPomodoros}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '个番茄',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                '${taskProvider.todayCompletedTasks}',
                '完成任务',
              ),
              _buildStatItem(
                '${taskProvider.todayTotalPomodoros * 25}',
                '专注分钟',
              ),
              _buildStatItem(
                '连续${taskProvider.todayTotalPomodoros ~/ 4}天',
                '连续打卡',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStart(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '快速开始',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickStartCard(
                context,
                '25分钟',
                '标准番茄',
                AppTheme.primaryColor,
                () => context.read<TimerProvider>().setFocusDuration(25),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickStartCard(
                context,
                '45分钟',
                '深度专注',
                const Color(0xFF9B59B6),
                () => context.read<TimerProvider>().setFocusDuration(45),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickStartCard(
                context,
                '60分钟',
                '超级专注',
                const Color(0xFF3498DB),
                () => context.read<TimerProvider>().setFocusDuration(60),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStartCard(
    BuildContext context,
    String duration,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        onTap();
        Navigator.pushNamed(context, '/timer');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Text(
              duration,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingTasks(BuildContext context, TaskProvider taskProvider) {
    final pendingTasks = taskProvider.pendingTasks.take(3).toList();

    if (pendingTasks.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 12),
            const Text(
              '暂无待办任务',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/tasks'),
              icon: const Icon(Icons.add),
              label: const Text('添加任务'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '待办任务',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/tasks'),
              child: const Text('查看全部'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...pendingTasks.map((task) => _buildTaskCard(context, task)),
      ],
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${task.completedPomodoros}/${task.totalPomodoros}',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (task.description != null && task.description!.isNotEmpty)
                  Text(
                    task.description!,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/timer'),
            icon: const Icon(Icons.play_circle_filled),
            color: AppTheme.primaryColor,
            iconSize: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementTip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.warning.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.emoji_events,
              color: AppTheme.warning,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '成就提示',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '完成3个番茄钟可解锁"初学者"成就',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
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
