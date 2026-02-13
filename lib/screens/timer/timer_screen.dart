import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focus_timer/providers/timer_provider.dart';
import 'package:focus_timer/theme/app_theme.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with TickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);

    return Column(
      children: [
        // 模式切换标签
        _buildModeTabs(timerProvider),
        
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 计时器圆形进度
              _buildTimerCircle(timerProvider),
              const SizedBox(height: 32),
              
              // 计时按钮
              _buildTimerControls(timerProvider),
              const SizedBox(height: 32),
              
              // 当前任务提示
              _buildCurrentTaskTip(),
            ],
          ),
        ),
        
        // 白噪音选择
        _buildSoundSelector(),
      ],
    );
  }

  Widget _buildModeTabs(TimerProvider timerProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildModeTab(
            '专注',
            timerProvider.mode == TimerMode.focus,
            AppTheme.primaryColor,
            () => timerProvider.reset(),
          ),
          _buildModeTab(
            '短休',
            timerProvider.mode == TimerMode.shortBreak,
            AppTheme.secondaryColor,
            () => timerProvider.skip(),
          ),
          _buildModeTab(
            '长休',
            timerProvider.mode == TimerMode.longBreak,
            const Color(0xFF45B7D1),
            () => timerProvider.skip(),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab(
    String label,
    bool isSelected,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerCircle(TimerProvider timerProvider) {
    final progress = timerProvider.currentSeconds /
        (timerProvider.mode == TimerMode.focus
            ? timerProvider.focusDuration * 60
            : timerProvider.mode == TimerMode.shortBreak
                ? timerProvider.shortBreakDuration * 60
                : timerProvider.longBreakDuration * 60);

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 280,
          height: 280,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 8,
            backgroundColor: AppTheme.cardColor,
            valueColor: AlwaysStoppedAnimation<Color>(
              timerProvider.modeColor,
            ),
          ),
        ),
        Column(
          children: [
            Text(
              timerProvider.formattedTime,
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: timerProvider.modeColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                timerProvider.modeText,
                style: TextStyle(
                  color: timerProvider.modeColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimerControls(TimerProvider timerProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 重置按钮
        FloatingActionButton.small(
          onPressed: timerProvider.reset,
          backgroundColor: AppTheme.cardColor,
          child: const Icon(Icons.replay, color: AppTheme.textSecondary),
        ),
        const SizedBox(width: 24),
        
        // 开始/暂停按钮
        FloatingActionButton.large(
          onPressed: () {
            if (timerProvider.isRunning) {
              timerProvider.pause();
            } else {
              timerProvider.start();
            }
          },
          backgroundColor: timerProvider.modeColor,
          child: Icon(
            timerProvider.isRunning ? Icons.pause : Icons.play_arrow,
            size: 36,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 24),
        
        // 跳过按钮
        FloatingActionButton.small(
          onPressed: timerProvider.skip,
          backgroundColor: AppTheme.cardColor,
          child: const Icon(Icons.skip_next, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildCurrentTaskTip() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.info_outline, color: AppTheme.textSecondary, size: 18),
          SizedBox(width: 8),
          Text(
            '选择一个任务以开始计时',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundSelector() {
    final sounds = [
      ('雨声', 'rain'),
      ('白噪声', 'white_noise'),
      ('森林', 'forest'),
      ('咖啡馆', 'cafe'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '白噪音',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: sounds.map((sound) {
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      sound.$1,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
