import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class AppTheme {
  AppTheme._();

  // ========================================
  // الثيم الفاتح
  // ========================================
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary:                 AppColors.primaryGreen,
      onPrimary:               AppColors.textOnGreen,
      secondary:               AppColors.accentGold,
      onSecondary:             AppColors.textDark,
      surface:                 AppColors.bgCard,
      onSurface:               AppColors.textDark,
      surfaceContainerHighest: AppColors.bgPattern,
      error:                   Color(0xFFB00020),
      onError:                 Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.bgLight,
    fontFamily: 'Scheherazade',
    textTheme: _buildTextTheme(AppColors.textDark),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: AppColors.textOnGreen,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily:  'Scheherazade',
        fontSize:    AppDimensions.fontXl,
        fontWeight:  FontWeight.bold,
        color:       AppColors.textOnGreen,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor:           Colors.transparent,
        statusBarIconBrightness:  Brightness.light,
      ),
      iconTheme: IconThemeData(color: AppColors.textOnGreen),
    ),
    // ✅ إصلاح: CardThemeData بدلاً من CardTheme
    cardTheme: CardThemeData(
      elevation: AppDimensions.cardElevation,
      color: AppColors.bgCard,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.textOnGreen,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.lg,
          vertical:   AppDimensions.sm + 4,
        ),
        textStyle: const TextStyle(
          fontFamily:  'Scheherazade',
          fontSize:    AppDimensions.fontMd,
          fontWeight:  FontWeight.bold,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        textStyle: const TextStyle(
          fontFamily: 'Scheherazade',
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical:   AppDimensions.sm,
      ),
      hintStyle: const TextStyle(
        fontFamily: 'Scheherazade',
        color:      AppColors.textLight,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color:     AppColors.divider,
      thickness: 1,
      space:     1,
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical:   AppDimensions.xs,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor:     AppColors.bgCard,
      selectedItemColor:   AppColors.primaryGreen,
      unselectedItemColor: AppColors.textLight,
      type:                BottomNavigationBarType.fixed,
      elevation:           8,
    ),
  );

  // ========================================
  // الثيم الداكن
  // ========================================
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary:                 AppColors.primaryGreenLight,
      onPrimary:               AppColors.textOnGreen,
      secondary:               AppColors.accentGold,
      onSecondary:             Colors.black,
      surface:                 AppColors.bgDarkCard,
      onSurface:               Colors.white,
      surfaceContainerHighest: AppColors.bgDarkSurface,
      error:                   Color(0xFFCF6679),
      onError:                 Colors.black,
    ),
    scaffoldBackgroundColor: AppColors.bgDark,
    fontFamily: 'Scheherazade',
    textTheme: _buildTextTheme(Colors.white),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bgDarkCard,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily:  'Scheherazade',
        fontSize:    AppDimensions.fontXl,
        fontWeight:  FontWeight.bold,
        color:       Colors.white,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor:           Colors.transparent,
        statusBarIconBrightness:  Brightness.light,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    // ✅ إصلاح: CardThemeData بدلاً من CardTheme
    cardTheme: CardThemeData(
      elevation: AppDimensions.cardElevation,
      color: AppColors.bgDarkCard,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreenLight,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.lg,
          vertical:   AppDimensions.sm + 4,
        ),
        textStyle: const TextStyle(
          fontFamily:  'Scheherazade',
          fontSize:    AppDimensions.fontMd,
          fontWeight:  FontWeight.bold,
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color:     AppColors.dividerDark,
      thickness: 1,
      space:     1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgDarkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(color: AppColors.primaryGreenLight, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical:   AppDimensions.sm,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor:     AppColors.bgDarkCard,
      selectedItemColor:   AppColors.primaryGreenLight,
      unselectedItemColor: Colors.white54,
      type:                BottomNavigationBarType.fixed,
      elevation:           8,
    ),
  );

  // ========================================
  // بناء نمط النص
  // ========================================
  static TextTheme _buildTextTheme(Color base) => TextTheme(
    displayLarge:   _ts(base, 32, FontWeight.bold),
    displayMedium:  _ts(base, 28, FontWeight.bold),
    displaySmall:   _ts(base, 24, FontWeight.bold),
    headlineLarge:  _ts(base, 22, FontWeight.bold),
    headlineMedium: _ts(base, 20, FontWeight.w600),
    headlineSmall:  _ts(base, 18, FontWeight.w600),
    titleLarge:     _ts(base, 17, FontWeight.w600),
    titleMedium:    _ts(base, 16, FontWeight.w500),
    titleSmall:     _ts(base, 14, FontWeight.w500),
    bodyLarge:      _ts(base, 16, FontWeight.normal),
    bodyMedium:     _ts(base, 14, FontWeight.normal),
    bodySmall:      _ts(base, 12, FontWeight.normal),
    labelLarge:     _ts(base, 14, FontWeight.w600),
    labelMedium:    _ts(base, 12, FontWeight.w500),
    labelSmall:     _ts(base, 11, FontWeight.w500),
  );

  static TextStyle _ts(Color color, double size, FontWeight weight) => TextStyle(
    color:      color,
    fontSize:   size,
    fontWeight: weight,
    fontFamily: 'Scheherazade',
    height:     1.7,
  );
}
