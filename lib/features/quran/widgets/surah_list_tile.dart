import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/surah_model.dart';

/// عنصر قائمة السورة - بتصميم دائرة مرقّمة + تفاصيل
class SurahListTile extends StatelessWidget {
  final SurahModel surah;
  final VoidCallback onTap;
  final bool isLastRead;

  const SurahListTile({
    super.key,
    required this.surah,
    required this.onTap,
    this.isLastRead = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.md,
            vertical:   AppDimensions.sm + 2,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.bgDarkCard : AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: isLastRead
                ? Border.all(color: AppColors.accentGold, width: 1.5)
                : null,
          ),
          child: Row(
            children: [
              // ===== رقم السورة في دائرة مزخرفة =====
              _SurahNumberBadge(number: surah.number),

              const SizedBox(width: AppDimensions.md),

              // ===== معلومات السورة =====
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سورة ${surah.name}',
                      style: const TextStyle(
                        fontFamily: 'Scheherazade',
                        fontSize:   AppDimensions.fontLg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          surah.isMeccan
                              ? Icons.location_city_rounded
                              : Icons.mosque_rounded,
                          size: 14,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${surah.revelationLabel} • ${surah.ayahCount} آية',
                          style: const TextStyle(
                            fontFamily: 'Scheherazade',
                            fontSize:   AppDimensions.fontSm,
                            color:      AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ===== أيقونة آخر قراءة =====
              if (isLastRead)
                const Padding(
                  padding: EdgeInsets.only(left: AppDimensions.sm),
                  child: Icon(
                    Icons.bookmark_rounded,
                    color: AppColors.accentGold,
                    size: AppDimensions.iconSm,
                  ),
                ),

              const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.textLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// شارة رقم السورة - تصميم دائري إسلامي
class _SurahNumberBadge extends StatelessWidget {
  final int number;
  const _SurahNumberBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$number',
          style: const TextStyle(
            color:      Colors.white,
            fontSize:   AppDimensions.fontMd,
            fontWeight: FontWeight.bold,
            fontFamily: 'Scheherazade',
          ),
        ),
      ),
    );
  }
}
