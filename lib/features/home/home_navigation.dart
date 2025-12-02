// lib/features/home/home_navigation.dart
import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../tasks/tasks_screen.dart';
import '../timer/timer_screen.dart';
import '../profile/profile_screen.dart';
import '../../core/utils/app_colors.dart';

class HomeNavigation extends StatefulWidget {
  final String name;
  final String email;
  final VoidCallback? onThemeToggle;

  const HomeNavigation({
    super.key,
    required this.name,
    required this.email,
    this.onThemeToggle,
  });

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  int _currentIndex = 0;

  List<Widget> get _screens => [
    HomeScreen(userName: widget.name, onToggleDarkMode: widget.onThemeToggle),
    TasksScreen(),
    TimerScreen(),
    ProfileScreen(name: widget.name, email: widget.email),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.checklist), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Focus'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
