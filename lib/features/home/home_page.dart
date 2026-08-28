import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/section_card.dart';
import '../quran/pages/quran_page.dart';
import '../tasmee3/pages/tasmee3_page.dart';
import '../azkar/pages/azkar_page.dart';
import '../tafsir/pages/tafsir_page.dart';
import '../fiqh/pages/fiqh_page.dart';
import '../library/pages/library_page.dart';
import '../audio/pages/audio_page.dart';
import '../quiz/pages/quiz_page.dart';
import '../favorites/pages/favorites_page.dart';
import '../settings/pages/settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // ===== قائمة الأقسام =====
  static const List<_SectionData> _sections = [
    _SectionData(
      title: AppStrings.quran,
      icon:  Icons.menu_book_rounded,
      color: Color(0xFF1B5E20),
      index: 0,
    ),
    _SectionData(
      title: AppStrings.tasmee3,
      icon:  Icons.mic_rounded,
      color: Color(0xFF6A1B9A),
      index: 1,
    ),
    _SectionData(
      title: AppStrings.azkar,
      icon:  Icons.self_improvement_rounded,
      color: Color(0xFF00695C),
      index: 2,
    ),
    _SectionData(
      title: AppStrings.tafsir,
      icon:  Icons.auto_stories_rounded,
      color: Color(0xFF1565C0),
      index: 3,
    ),
    _SectionData(
      title: AppStrings.fiqh,
      icon:  Icons.balance_rounded,
      color: Color(0xFF4E342E),
      index: 4,
    ),
    _SectionData(
      title: AppStrings.library,
      icon:  Icons.local_library_rounded,
      color: Color(0xFF37474F),
      index: 5,
    ),
    _SectionData(
      title: AppStrings.audioLib,
      icon:  Icons.headphones_rounded,
      color: Color(0xFF880E4F),
      index: 6,
    ),
    _SectionData(
      title: AppStrings.quiz,
      icon:  Icons.quiz_rounded,
      color: Color(0xFFF57F17),
      index: 7,
    ),
    _SectionData(
      title: AppStrings.favorites,
      icon:  Icons.favorite_rounded,
      color: Color(0xFFC62828),
      index: 8,
    ),
    _SectionData(
      title: AppStrings.settings,
      icon:  Icons.settings_rounded,
      color: Color(0xFF424242),
      index: 9,
    ),
  ];

  void _navigate(BuildContext context, int index) {
    final Widget page;
    switch (index) {
      case 0:
        page = const QuranPage();
        break;
      case 1:
        page = const Tasmee3Page();
        break;
      case 2:
        page = const AzkarPage();
        break;
      case 3:
        page = const TafsirPage();
        break;
      case 4:
        page = const FiqhPage();
        break;
      case 5:
        page = const LibraryPage();
        break;
      case 6:
        page = const AudioPage();
        break;
      case 7:
        page = const QuizPage();
        break;
      case 8:
        page = const FavoritesPage();
        break;
      case 9:
        page = const SettingsPage();
        break;
      default:
        page = const QuranPage();
    }
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ===== السليفر أبار =====
          SliverAppBar(
            expandedHeight: AppDimensions.headerExpanded,
            pinned:  true,
            stretch: true,
            backgroundColor: AppColors.primaryGreen,
            // ✅ إصلاح: SystemUiOverlayStyle تحتاج import services
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor:           Colors.transparent,
              statusBarIconBrightness:  Brightness.light,
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.settings_outlined,
                  color: Colors.white,
                ),
                tooltip: AppStrings.settings,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const SettingsPage(),
                  ),
                ),
              ),
            ],
            flexibleSpace: const FlexibleSpaceBar(
              centerTitle: true,
              stretchModes: [
                StretchMode.zoomBackground,
                StretchMode.fadeTitle,
              ],
              title: _AppBarTitle(),
              background: _HomeHeader(),
            ),
          ),

          // ===== الشبكة الرئيسية =====
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.md,
              AppDimensions.md,
              AppDimensions.md,
              0,
            ),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final s = _sections[i];
                  return SectionCard(
                    title:          s.title,
                    icon:           s.icon,
                    color:          s.color,
                    animationIndex: s.index,
                    onTap: () => _navigate(context, s.index),
                  );
                },
                childCount: _sections.length,
              ),
              // ✅ إصلاح: قيم ثابتة مباشرة بدلاً من AppDimensions في const
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:   2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing:  12.0,
                childAspectRatio: 1.05,
              ),
            ),
          ),

          // ===== تذييل =====
          const SliverToBoxAdapter(
            child: _Footer(),
          ),
        ],
      ),
    );
  }
}

// ========================================
// عنوان الـ AppBar
// ========================================
class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          AppStrings.appName,
          style: TextStyle(
            color:      Colors.white,
            fontSize:   20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Scheherazade',
          ),
        ),
        Text(
          AppStrings.appSubtitle,
          style: TextStyle(
            color:      Colors.white.withValues(alpha: 0.80),
            fontSize:   11,
            fontFamily: 'Scheherazade',
          ),
        ),
      ],
    );
  }
}

// ========================================
// خلفية الهيدر
// ========================================
class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // الدوائر الزخرفية
          Positioned(
            top: -50,
            right: -50,
            child: _GlowCircle(
              size: 180,
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: _GlowCircle(
              size: 140,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          Positioned(
            top: 50,
            left: 40,
            child: _GlowCircle(
              size: 70,
              color: Colors.white.withValues(alpha: 0.09),
            ),
          ),
          Positioned(
            bottom: 60,
            right: 80,
            child: _GlowCircle(
              size: 50,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),

          // البسملة في المنتصف
          Positioned(
            top: 0,
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    AppStrings.basmala,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Uthmanic',
                      fontSize:   18,
                      color:      AppColors.accentGold,
                      shadows: [
                        Shadow(
                          color:      Colors.black38,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 900.ms, delay: 300.ms),
                  const SizedBox(height: 8),
                  Container(
                    width: 120,
                    height: 1,
                    decoration: const BoxDecoration(
                      gradient: AppColors.goldGradient,
                    ),
                  ).animate().scaleX(duration: 700.ms, delay: 600.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// دائرة زخرفية
// ========================================
class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

// ========================================
// تذييل الصفحة
// ========================================
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.xl),
      child: Text(
        '﴿ إِنَّ الْقُرْآنَ يَهْدِي لِلَّتِي هِيَ أَقْوَمُ ﴾',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Uthmanic',
          fontSize:   16,
          color:      AppColors.primaryGreen.withValues(alpha: 0.65),
        ),
      ),
    );
  }
}

// ========================================
// بيانات القسم (const + immutable)
// ========================================
class _SectionData {
  final String title;
  final IconData icon;
  final Color color;
  final int index;

  const _SectionData({
    required this.title,
    required this.icon,
    required this.color,
    required this.index,
  });
}
