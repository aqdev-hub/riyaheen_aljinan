import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Widget موحّد يُعرض في الصفحات التي لا تزال قيد الإنشاء
class ComingSoonBody extends StatelessWidget {
  final String sectionName;
  final IconData icon;
  final Color? color;

  const ComingSoonBody({
    super.key,
    required this.sectionName,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primaryGreen;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ إصلاح: withValues بدلاً من withOpacity
            Container(
              padding: const EdgeInsets.all(AppDimensions.lg),
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size:  AppDimensions.iconXl,
                color: c,
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            Text(
              sectionName,
              style: TextStyle(
                fontFamily: 'Scheherazade',
                fontSize:   AppDimensions.fontXxl,
                fontWeight: FontWeight.bold,
                color:      c,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            const Text(
              'هذا القسم قيد الإنشاء\nسيكون متاحاً قريباً إن شاء الله',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Scheherazade',
                fontSize:   AppDimensions.fontLg,
                color:      AppColors.textMedium,
                height:     1.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
