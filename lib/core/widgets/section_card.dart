import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_dimensions.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int animationIndex;

  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ حساب اللون الداكن بدون withOpacity
    final darkColor = Color.lerp(color, Colors.black, 0.28) ?? color;
    final shadowColor = color.withValues(alpha: 0.35);
    final iconBgColor = Colors.white.withValues(alpha: 0.22);
    final circle1Color = Colors.white.withValues(alpha: 0.10);
    final circle2Color = Colors.white.withValues(alpha: 0.08);

    return Animate(
      effects: [
        FadeEffect(
          duration: 350.ms,
          delay: Duration(milliseconds: animationIndex * 55),
          curve: Curves.easeOut,
        ),
        ScaleEffect(
          begin: const Offset(0.88, 0.88),
          end: const Offset(1.0, 1.0),
          duration: 350.ms,
          delay: Duration(milliseconds: animationIndex * 55),
          curve: Curves.easeOut,
        ),
      ],
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              gradient: LinearGradient(
                colors: [color, darkColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // دائرة زخرفية كبيرة
                Positioned(
                  right: -24,
                  bottom: -24,
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: circle1Color,
                    ),
                  ),
                ),
                // دائرة زخرفية صغيرة
                Positioned(
                  right: 12,
                  top: -18,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: circle2Color,
                    ),
                  ),
                ),
                // المحتوى الرئيسي
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusSm + 2,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: AppDimensions.iconMd,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      Text(
                        title,
                        style: const TextStyle(
                          color:      Colors.white,
                          fontSize:   AppDimensions.fontMd,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Scheherazade',
                          shadows: [
                            Shadow(
                              color:      Colors.black26,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
