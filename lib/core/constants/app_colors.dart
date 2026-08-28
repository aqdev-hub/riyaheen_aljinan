import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ===== الألوان الرئيسية =====
  static const Color primaryGreen      = Color(0xFF1B5E20);
  static const Color primaryGreenMid   = Color(0xFF2E7D32);
  static const Color primaryGreenLight = Color(0xFF43A047);
  static const Color accentGold        = Color(0xFFD4A843);
  static const Color accentGoldLight   = Color(0xFFFFD700);

  // ===== خلفيات الوضع الفاتح =====
  static const Color bgLight     = Color(0xFFF5F5F0);
  static const Color bgCard      = Color(0xFFFFFFFF);
  static const Color bgPattern   = Color(0xFFF0EDE5);

  // ===== خلفيات الوضع الداكن =====
  static const Color bgDark        = Color(0xFF0D1B0E);
  static const Color bgDarkCard    = Color(0xFF1A2E1B);
  static const Color bgDarkSurface = Color(0xFF152415);

  // ===== النصوص =====
  static const Color textDark    = Color(0xFF1A1A1A);
  static const Color textMedium  = Color(0xFF4A4A4A);
  static const Color textLight   = Color(0xFF8A8A8A);
  static const Color textOnGreen = Color(0xFFFFFFFF);
  static const Color textGold    = Color(0xFFD4A843);

  // ===== حالات التسميع =====
  static const Color correct  = Color(0xFF4CAF50);
  static const Color wrong    = Color(0xFFF44336);
  static const Color warning  = Color(0xFFFFC107);
  static const Color hint     = Color(0xFF2196F3);

  // ===== الفواصل =====
  static const Color divider     = Color(0xFFE0D9CC);
  static const Color dividerDark = Color(0xFF2A3D2B);

  // ===== التدرجات =====
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, primaryGreenMid],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4A843), Color(0xFFFFD700), Color(0xFFD4A843)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
