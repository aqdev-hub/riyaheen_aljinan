import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../data/quran_repository.dart';
import '../models/ayah_model.dart';
import 'surah_reading_page.dart';

class QuranSearchPage extends StatefulWidget {
  const QuranSearchPage({super.key});

  @override
  State<QuranSearchPage> createState() => _QuranSearchPageState();
}

class _QuranSearchPageState extends State<QuranSearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<AyahModel> _results = [];
  bool _loading = false;
  bool _searched = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _searched = false;
      });
      return;
    }

    setState(() => _loading = true);

    final results = await QuranRepository.instance.searchInQuran(query);

    if (mounted) {
      setState(() {
        _results = results;
        _loading = false;
        _searched = true;
      });
    }
  }

  void _openAyah(AyahModel ayah) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SurahReadingPage(
          surahNumber: ayah.surah,
          scrollToAyah: ayah.ayah,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            fontFamily: 'Scheherazade',
            fontSize: AppDimensions.fontLg,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: 'بحث في القرآن الكريم...',
            hintStyle: TextStyle(
              fontFamily: 'Scheherazade',
              color: Colors.white.withValues(alpha: 0.7),
            ),
            border: InputBorder.none,
          ),
          onChanged: _search,
          onSubmitted: _search,
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              onPressed: () {
                _controller.clear();
                _search('');
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_searched) {
      return _buildHint();
    }

    if (_results.isEmpty) {
      return _buildNoResults();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.md),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.sm),
      itemBuilder: (context, index) {
        final ayah = _results[index];
        return _SearchResultCard(
          ayah: ayah,
          query: _controller.text,
          onTap: () => _openAyah(ayah),
        );
      },
    );
  }

  Widget _buildHint() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_rounded,
              size: 64,
              color: AppColors.primaryGreen.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppDimensions.md),
            const Text(
              'ابحث في آيات القرآن الكريم',
              style: TextStyle(
                fontFamily: 'Scheherazade',
                fontSize: AppDimensions.fontLg,
                fontWeight: FontWeight.bold,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            const Text(
              'يمكنك البحث بدون تشكيل',
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

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppColors.textLight.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppDimensions.md),
            const Text(
              'لا توجد نتائج',
              style: TextStyle(
                fontFamily: 'Scheherazade',
                fontSize: AppDimensions.fontLg,
                fontWeight: FontWeight.bold,
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة نتيجة البحث
class _SearchResultCard extends StatelessWidget {
  final AyahModel ayah;
  final String query;
  final VoidCallback onTap;

  const _SearchResultCard({
    required this.ayah,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معلومات السورة والآية
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                    child: Text(
                      'سورة ${ayah.surah} - آية ${ayah.ayah}',
                      style: const TextStyle(
                        fontFamily: 'Scheherazade',
                        fontSize: AppDimensions.fontXs,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_left_rounded, color: AppColors.textLight),
                ],
              ),
              const SizedBox(height: AppDimensions.sm),

              // نص الآية
              Text(
                ayah.text,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: 'Uthmanic',
                  fontSize: 20,
                  height: 1.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
