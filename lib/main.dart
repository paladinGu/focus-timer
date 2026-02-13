import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focus_timer/theme/app_theme.dart';
import 'package:focus_timer/providers/timer_provider.dart';
import 'package:focus_timer/providers/task_provider.dart';
import 'package:focus_timer/screens/home/home_screen.dart';
import 'package:focus_timer/screens/timer/timer_screen.dart';
import 'package:focus_timer/screens/tasks/tasks_screen.dart';
import 'package:focus_timer/screens/stats/stats_screen.dart';
import 'package:focus_timer/screens/settings/settings_screen.dart';

void main() {
  runApp(const FocusTimerApp());
}

class FocusTimerApp extends StatelessWidget {
  const FocusTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        title: '专注时光',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainScreen(),
        routes: {
          '/timer': (_) => const TimerScreen(),
          '/tasks': (_) => const TasksScreen(),
          '/stats': (_) => const StatsScreen(),
          '/settings': (_) => const SettingsScreen(),
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TimerScreen(),
    const TasksScreen(),
    const StatsScreen(),
    const SettingsScreen(),
  ];

  final List<String> _titles = [
    '专注时光',
    '计时器',
    '任务',
    '统计',
    '设置',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: '计时',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: '任务',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: '统计',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}
