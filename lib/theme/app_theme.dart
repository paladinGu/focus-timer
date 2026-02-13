import 'package:flutter/material.dart';

class AppTheme {
  // 配色方案
  static const Color primaryColor = Color(0xFFFF6B6B); // 橙红色
  static const Color secondaryColor = Color(0xFF4ECDC4); // 青绿色
  static const Color backgroundColor = Color(0xFF1A1A2E); // 深色背景
  static const Color cardColor = Color(0xFF16213E); // 卡片颜色
  static const Color surfaceColor = Color(0xFF0F3460); // 表面颜色
  static const Color textPrimary = Color(0xFFFFFFFF); // 主文字
  static const Color textSecondary = Color(0xFFB8B8B8); // 次要文字
  static const Color success = Color(0xFF4ECDC4);
  static const Color warning = Color(0xFFFFE66D);
  static const Color error = Color(0xFFFF6B6B);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        background: backgroundColor,
        surface: cardColor,
        onPrimary: textPrimary,
        secondary: secondaryColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        indicatorColor: primaryColor.withOpacity(0.3),
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          color: textPrimary,
          fontSize: 32,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          color: textPrimary,
          fontSize: 24,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontSize: 20,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Poppins',
          color: textPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Poppins',
          color: textSecondary,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
