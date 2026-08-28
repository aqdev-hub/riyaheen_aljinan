import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../data/quran_repository.dart';
import '../models/surah_model.dart';
import '../providers/quran_settings_provider.dart';
import '../widgets/surah_list_tile.dart';
import 'surah_reading_page.dart';
import 'quran_search_page.dart';
import 'bookmarks_page.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Future<List<SurahModel>>? _surahsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _surahsFuture = QuranRepository.instance.getSurahList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openSurah(BuildContext context, int surahNumber, {int? startAyah}) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SurahReadingPage(
          surahNumber: surahNumber,
          scrollToAyah: startAyah,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<QuranSettingsProvider>();

    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.quran,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            tooltip: AppStrings.search,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const QuranSearchPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_rounded, color: Colors.white),
            tooltip: AppStrings.favorites,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const BookmarksPage(),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentGold,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontFamily: 'Scheherazade',
            fontWeight: FontWeight.bold,
            fontSize: AppDimensions.fontMd,
          ),
          tabs: const [
            Tab(text: 'السور'),
            Tab(text: 'الأجزاء'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSurahsTab(settings),
          _buildJuzTab(settings),
        ],
      ),
    );
  }

  // ========================================
  // تبويب السور
  // ========================================
  Widget _buildSurahsTab(QuranSettingsProvider settings) {
    return FutureBuilder<List<SurahModel>>(
      future: _surahsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final surahs = snapshot.data ?? [];
        if (surahs.isEmpty) {
          return _buildEmptyState();
        }

        return CustomScrollView(
          slivers: [
            // ===== بطاقة "آخر قراءة" =====
            if (settings.isLoaded)
              SliverToBoxAdapter(
                child: _LastReadCard(
                  surahs: surahs,
                  settings: settings,
                  onTap: () => _openSurah(
                    context,
                    settings.lastSurah,
                    startAyah: settings.lastAyah,
                  ),
                ),
              ),

            // ===== قائمة السور =====
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.md,
                vertical:   AppDimensions.sm,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final surah = surahs[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
                      child: SurahListTile(
                        surah: surah,
                        isLastRead: settings.lastSurah == surah.number,
                        onTap: () => _openSurah(context, surah.number),
                      ),
                    );
                  },
                  childCount: surahs.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.xl),
            ),
          ],
        );
      },
    );
  }

  // ========================================
  // تبويب الأجزاء (30 جزء)
  // ========================================
  Widget _buildJuzTab(QuranSettingsProvider settings) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppDimensions.sm,
        mainAxisSpacing: AppDimensions.sm,
        childAspectRatio: 1.0,
      ),
      itemCount: 30,
      itemBuilder: (context, index) {
        final juzNumber = index + 1;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openJuz(juzNumber),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bookmark_border_rounded, color: Colors.white, size: 28),
                    const SizedBox(height: 6),
                    Text(
                      'الجزء $juzNumber',
                      style: const TextStyle(
                        fontFamily: 'Scheherazade',
                        fontSize:   AppDimensions.fontMd,
                        fontWeight: FontWeight.bold,
                        color:      Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// خريطة تقريبية لبداية كل جزء (رقم السورة، رقم الآية)
  /// هذه الخريطة معيارية وثابتة في كل نسخ القرآن
  static const Map<int, (int, int)> _juzStartMap = {
    1: (1, 1),    2: (2, 142),  3: (2, 253),  4: (3, 92),
    5: (4, 24),   6: (4, 148),  7: (5, 82),   8: (6, 111),
    9: (7, 88),   10: (8, 41),  11: (9, 93),  12: (11, 6),
    13: (12, 53), 14: (15, 1),  15: (17, 1),  16: (18, 75),
    17: (21, 1),  18: (23, 1),  19: (25, 21), 20: (27, 56),
    21: (29, 46), 22: (33, 31), 23: (36, 28), 24: (39, 32),
    25: (41, 47), 26: (46, 1),  27: (51, 31), 28: (58, 1),
    29: (67, 1),  30: (78, 1),
  };

  void _openJuz(int juzNumber) {
    final start = _juzStartMap[juzNumber];
    if (start == null) return;
    _openSurah(context, start.$1, startAyah: start.$2);
  }

  // ========================================
  // حالات خاصة
  // ========================================
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.wrong),
            const SizedBox(height: AppDimensions.md),
            const Text(
              'حدث خطأ في تحميل بيانات القرآن',
              style: TextStyle(
                fontFamily: 'Scheherazade',
                fontSize:   AppDimensions.fontLg,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
           const Text(
              'تأكد من وجود ملف surah_info.json في assets/data/quran/',
              textAlign: TextAlign.center,
              style:  TextStyle(
                fontFamily: 'Scheherazade',
                fontSize:   AppDimensions.fontSm,
                color:      AppColors.textLight,
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _surahsFuture = QuranRepository.instance.getSurahList();
                });
              },
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        AppStrings.noData,
        style: TextStyle(fontFamily: 'Scheherazade', fontSize: AppDimensions.fontLg),
      ),
    );
  }
}

// ========================================
// بطاقة "آخر قراءة"
// ========================================
class _LastReadCard extends StatelessWidget {
  final List<SurahModel> surahs;
  final QuranSettingsProvider settings;
  final VoidCallback onTap;

  const _LastReadCard({
    required this.surahs,
    required this.settings,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    SurahModel? lastSurah;
    for (final s in surahs) {
      if (s.number == settings.lastSurah) {
        lastSurah = s;
        break;
      }
    }
    if (lastSurah == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.md,
        AppDimensions.md,
        AppDimensions.md,
        0,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accentGold, Color(0xFFE5B94E)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentGold.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.sm),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: Colors.white,
                    size: AppDimensions.iconMd,
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'متابعة القراءة',
                        style: TextStyle(
                          fontFamily: 'Scheherazade',
                          fontSize:   AppDimensions.fontSm,
                          color:      Colors.white,
                        ),
                      ),
                      Text(
                        'سورة ${lastSurah.name} - آية ${settings.lastAyah}',
                        style: const TextStyle(
                          fontFamily: 'Scheherazade',
                          fontSize:   AppDimensions.fontLg,
                          fontWeight: FontWeight.bold,
                          color:      Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
