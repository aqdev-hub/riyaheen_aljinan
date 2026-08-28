import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../data/quran_repository.dart';
import '../models/ayah_model.dart';
import '../models/surah_model.dart';
import '../providers/quran_settings_provider.dart';
import 'surah_reading_page.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  Map<int, SurahModel> _surahsByNumber = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSurahNames();
  }

  Future<void> _loadSurahNames() async {
    final surahs = await QuranRepository.instance.getSurahList();
    if (mounted) {
      setState(() {
        _surahsByNumber = {for (final s in surahs) s.number: s};
        _loading = false;
      });
    }
  }

  void _openAyah(int surah, int ayah) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SurahReadingPage(
          surahNumber: surah,
          scrollToAyah: ayah,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<QuranSettingsProvider>();
    final bookmarks = settings.bookmarksList;

    return Scaffold(
      appBar: const CustomAppBar(title: AppStrings.favorites),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : bookmarks.isEmpty
              ? _buildEmptyState()
              : _buildList(bookmarks, settings),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_border_rounded,
              size: 64,
              color: AppColors.accentGold.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppDimensions.md),
            const Text(
              'لا توجد إشارات مرجعية',
              style: TextStyle(
                fontFamily: 'Scheherazade',
                fontSize: AppDimensions.fontLg,
                fontWeight: FontWeight.bold,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            const Text(
              'اضغط مطولاً على أي آية لإضافتها إلى المفضلة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Scheherazade',
                fontSize: AppDimensions.fontSm,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<(int, int)> bookmarks, QuranSettingsProvider settings) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.md),
      itemCount: bookmarks.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.sm),
      itemBuilder: (context, index) {
        final (surah, ayah) = bookmarks[index];
        final surahInfo = _surahsByNumber[surah];

        return FutureBuilder<AyahModel?>(
          future: QuranRepository.instance.getAyah(surah, ayah),
          builder: (context, snapshot) {
            final ayahModel = snapshot.data;

            return Material(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              child: InkWell(
                onTap: () => _openAyah(surah, ayah),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentGold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                            ),
                            child: Text(
                              surahInfo != null
                                  ? 'سورة ${surahInfo.name} - آية $ayah'
                                  : 'سورة $surah - آية $ayah',
                              style: const TextStyle(
                                fontFamily: 'Scheherazade',
                                fontSize: AppDimensions.fontXs,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentGold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(
                              Icons.bookmark_remove_rounded,
                              color: AppColors.wrong,
                              size: AppDimensions.iconSm,
                            ),
                            onPressed: () => settings.toggleBookmark(surah, ayah),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      if (ayahModel != null)
                        Text(
                          ayahModel.text,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Uthmanic',
                            fontSize: 20,
                            height: 1.8,
                          ),
                        )
                      else
                        const SizedBox(
                          height: 24,
                          child: Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
