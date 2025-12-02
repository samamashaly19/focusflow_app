// lib/core/utils/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF90CAF9);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color background = Color(0xFFE3F2FD);
  static const Color accent = Color(0xFF64B5F6);

  static LinearGradient mainGradient = const LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
