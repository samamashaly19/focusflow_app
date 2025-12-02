// lib/main.dart
import 'package:flutter/material.dart';
import 'features/login/login_screen.dart';
import 'core/utils/app_colors.dart';

void main() {
  runApp(const FocusFlowApp());
}

class FocusFlowApp extends StatefulWidget {
  const FocusFlowApp({super.key});

  @override
  State<FocusFlowApp> createState() => _FocusFlowAppState();
}

class _FocusFlowAppState extends State<FocusFlowApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus-Flow',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primaryDark,
        scaffoldBackgroundColor: Colors.grey.shade900,
        appBarTheme: AppBarTheme(backgroundColor: AppColors.primaryDark),
      ),
      home: LoginScreen(onThemeToggle: toggleTheme),
    );
  }
}
