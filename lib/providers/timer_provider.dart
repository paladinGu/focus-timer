import 'package:flutter/material.dart';

enum TimerMode { focus, shortBreak, longBreak }

class TimerProvider with ChangeNotifier {
  // 计时器状态
  TimerMode _mode = TimerMode.focus;
  int _focusDuration = 25; // 专注时长（分钟）
  int _shortBreakDuration = 5; // 短休息时长
  int _longBreakDuration = 15; // 长休息时长
  int _pomodorosUntilLongBreak = 4; // 多少个番茄钟后长休息

  int _currentSeconds = 25 * 60;
  bool _isRunning = false;
  int _completedPomodorosToday = 0;
  int _totalFocusMinutesToday = 0;

  // 倒计时定时器
  DateTime? _endTime;

  // Getter
  TimerMode get mode => _mode;
  int get focusDuration => _focusDuration;
  int get shortBreakDuration => _shortBreakDuration;
  int get longBreakDuration => _longBreakDuration;
  int get pomodorosUntilLongBreak => _pomodorosUntilLongBreak;
  int get currentSeconds => _currentSeconds;
  bool get isRunning => _isRunning;
  int get completedPomodorosToday => _completedPomodorosToday;
  int get totalFocusMinutesToday => _totalFocusMinutesToday;

  String get formattedTime {
    int minutes = _currentSeconds ~/ 60;
    int seconds = _currentSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get modeText {
    switch (_mode) {
      case TimerMode.focus:
        return '专注时间';
      case TimerMode.shortBreak:
        return '短休息';
      case TimerMode.longBreak:
        return '长休息';
    }
  }

  Color get modeColor {
    switch (_mode) {
      case TimerMode.focus:
        return const Color(0xFFFF6B6B);
      case TimerMode.shortBreak:
        return const Color(0xFF4ECDC4);
      case TimerMode.longBreak:
        return const Color(0xFF45B7D1);
    }
  }

  // 设置专注时长
  void setFocusDuration(int minutes) {
    _focusDuration = minutes;
    if (_mode == TimerMode.focus && !_isRunning) {
      _currentSeconds = minutes * 60;
    }
    notifyListeners();
  }

  // 开始计时
  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _endTime = DateTime.now().add(Duration(seconds: _currentSeconds));
    notifyListeners();
  }

  // 暂停计时
  void pause() {
    if (!_isRunning) return;
    _isRunning = false;
    if (_endTime != null) {
      _currentSeconds = _endTime!.difference(DateTime.now()).inSeconds;
      if (_currentSeconds < 0) _currentSeconds = 0;
    }
    notifyListeners();
  }

  // 重置计时
  void reset() {
    _isRunning = false;
    _endTime = null;
    _currentSeconds = _getDurationForMode() * 60;
    notifyListeners();
  }

  // 跳过当前阶段
  void skip() {
    _isRunning = false;
    _endTime = null;
    _moveToNextMode();
    notifyListeners();
  }

  // 计时完成
  void onTimerComplete() {
    _isRunning = false;
    _endTime = null;

    if (_mode == TimerMode.focus) {
      _completedPomodorosToday++;
      _totalFocusMinutesToday += _focusDuration;
    }

    _moveToNextMode();
    notifyListeners();
  }

  // 切换到下一个模式
  void _moveToNextMode() {
    switch (_mode) {
      case TimerMode.focus:
        if (_completedPomodorosToday % _pomodorosUntilLongBreak == 0) {
          _mode = TimerMode.longBreak;
          _currentSeconds = _longBreakDuration * 60;
        } else {
          _mode = TimerMode.shortBreak;
          _currentSeconds = _shortBreakDuration * 60;
        }
        break;
      case TimerMode.shortBreak:
      case TimerMode.longBreak:
        _mode = TimerMode.focus;
        _currentSeconds = _focusDuration * 60;
        break;
    }
  }

  int _getDurationForMode() {
    switch (_mode) {
      case TimerMode.focus:
        return _focusDuration;
      case TimerMode.shortBreak:
        return _shortBreakDuration;
      case TimerMode.longBreak:
        return _longBreakDuration;
    }
  }

  // 更新计时器（每秒调用）
  void update() {
    if (!_isRunning) return;

    if (_endTime != null) {
      _currentSeconds = _endTime!.difference(DateTime.now()).inSeconds;

      if (_currentSeconds <= 0) {
        onTimerComplete();
      } else {
        notifyListeners();
      }
    }
  }

  // 重置今日统计
  void resetTodayStats() {
    _completedPomodorosToday = 0;
    _totalFocusMinutesToday = 0;
    notifyListeners();
  }
}
