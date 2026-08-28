import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../models/ayah_model.dart';

/// Widget يعرض آية واحدة مع رقمها بشكل دائرة زخرفية
/// عند الضغط المطوّل يعرض قائمة الإجراءات (تفسير، نسخ، إشارة، مشاركة)
class AyahSpanData {
  final AyahModel ayah;
  final bool isBookmarked;
  final bool hasWordMeaning;

  const AyahSpanData({
    required this.ayah,
    this.isBookmarked = false,
    this.hasWordMeaning = false,
  });
}

/// شارة رقم الآية الدائرية الزخرفية (تُستخدم داخل RichText كـ WidgetSpan)
class AyahNumberBadge extends StatelessWidget {
  final int number;
  final bool isBookmarked;

  const AyahNumberBadge({
    super.key,
    required this.number,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isBookmarked ? AppColors.accentGold : AppColors.primaryGreen,
            width: 1.5,
          ),
          color: isBookmarked
              ? AppColors.accentGold.withValues(alpha: 0.15)
              : AppColors.primaryGreen.withValues(alpha: 0.08),
        ),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              fontFamily: 'Scheherazade',
              fontSize:   13,
              fontWeight: FontWeight.bold,
              color: isBookmarked ? AppColors.accentGold : AppColors.primaryGreen,
            ),
          ),
        ),
      ),
    );
  }
}

/// قائمة أسفل الشاشة لإجراءات الآية
class AyahActionsSheet extends StatelessWidget {
  final AyahModel ayah;
  final bool isBookmarked;
  final VoidCallback onShowTafsir;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onToggleBookmark;
  final VoidCallback? onShowWordMeanings;
  final bool hasWordMeanings;

  const AyahActionsSheet({
    super.key,
    required this.ayah,
    required this.isBookmarked,
    required this.onShowTafsir,
    required this.onCopy,
    required this.onShare,
    required this.onToggleBookmark,
    this.onShowWordMeanings,
    this.hasWordMeanings = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===== مقبض السحب =====
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppDimensions.md),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ===== عنوان =====
            Text(
              'الآية ${ayah.ayah} - سورة ${ayah.surah}',
              style: const TextStyle(
                fontFamily: 'Scheherazade',
                fontSize:   AppDimensions.fontLg,
                fontWeight: FontWeight.bold,
                color:      AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: AppDimensions.md),

            // ===== نص الآية =====
            Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: AppColors.bgPattern,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Text(
                ayah.text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Uthmanic',
                  fontSize:   22,
                  height:     1.8,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            // ===== شبكة الإجراءات =====
            GridView.count(
              crossAxisCount: hasWordMeanings ? 3 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppDimensions.sm,
              mainAxisSpacing: AppDimensions.sm,
              childAspectRatio: 1.3,
              children: [
                _ActionButton(
                  icon: Icons.menu_book_rounded,
                  label: 'التفسير',
                  color: AppColors.primaryGreen,
                  onTap: () {
                    Navigator.pop(context);
                    onShowTafsir();
                  },
                ),
                if (hasWordMeanings && onShowWordMeanings != null)
                  _ActionButton(
                    icon: Icons.translate_rounded,
                    label: 'معاني الكلمات',
                    color: const Color(0xFF6A1B9A),
                    onTap: () {
                      Navigator.pop(context);
                      onShowWordMeanings!();
                    },
                  ),
                _ActionButton(
                  icon: isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  label: isBookmarked ? 'إزالة الإشارة' : 'إشارة مرجعية',
                  color: AppColors.accentGold,
                  onTap: () {
                    Navigator.pop(context);
                    onToggleBookmark();
                  },
                ),
                _ActionButton(
                  icon: Icons.copy_rounded,
                  label: 'نسخ الآية',
                  color: AppColors.hint,
                  onTap: () {
                    Navigator.pop(context);
                    onCopy();
                  },
                ),
                _ActionButton(
                  icon: Icons.share_rounded,
                  label: 'مشاركة',
                  color: const Color(0xFF00897B),
                  onTap: () {
                    Navigator.pop(context);
                    onShare();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: AppDimensions.iconMd),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Scheherazade',
                fontSize:   AppDimensions.fontSm,
                fontWeight: FontWeight.w600,
                color:      color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
