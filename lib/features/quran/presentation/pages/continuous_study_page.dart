import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/quran_design/quran_design.dart';
import '../../domain/entities/ayah.dart';
import '../../domain/entities/surah.dart';
import '../../domain/entities/tafsir.dart';
import '../riverpod/quran_providers.dart';
import '../widgets/reader_sheets.dart' show QuranSettingsDialog;

/// أنواع القراءة المتصلة المتاحة من القائمة الأولى
enum StudyMode { tafsir, meanings, asbab }

extension on StudyMode {
  String get title {
    switch (this) {
      case StudyMode.tafsir:
        return 'التفسير';
      case StudyMode.meanings:
        return 'معاني الكلمات';
      case StudyMode.asbab:
        return 'سبب النزول';
    }
  }
}

/// قراءة متصلة صفحة بصفحة (بنفس ترقيم صفحات المصحف الـ604): كل آية تبدأ
/// في الصفحة، ومباشرة أسفلها محتواها (تفسير/معنى/سبب نزول) — كما في
/// التصميم المرجعي (الصورتان 2 و4)، مع إبقاء كل أدوات الآية (نسخ، مشاركة،
/// إشارة...) متاحة أيضًا من داخل "القرآن مطبوع" عند الضغط على الآية هناك.
class ContinuousStudyPage extends ConsumerStatefulWidget {
  final StudyMode mode;
  final int initialPage;

  const ContinuousStudyPage({super.key, required this.mode, required this.initialPage});

  @override
  ConsumerState<ContinuousStudyPage> createState() => _ContinuousStudyPageState();
}

class _ContinuousStudyPageState extends ConsumerState<ContinuousStudyPage> {
  late final PageController _controller = PageController(initialPage: widget.initialPage - 1);
  late int _currentPage = widget.initialPage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E6),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: 604,
                onPageChanged: (i) => setState(() => _currentPage = i + 1),
                itemBuilder: (context, index) => _PageBody(mode: widget.mode, pageNumber: index + 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: const Color(0xFF4A1F6B),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Colors.white, size: 20),
            onPressed: () => QuranSettingsDialog.show(context),
          ),
          Text(toEasternArabicDigits(_currentPage), style: const TextStyle(fontFamily: 'Scheherazade', color: Colors.white)),
          const Spacer(),
          Text(widget.mode.title, style: const TextStyle(fontFamily: 'Scheherazade', fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}

class _PageBody extends ConsumerWidget {
  final StudyMode mode;
  final int pageNumber;
  const _PageBody({required this.mode, required this.pageNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(quranRepositoryProvider);
    final settings = ref.watch(quranSettingsProvider);

    return FutureBuilder<List<Ayah>>(
      future: repo.getAyahsStartingOnPage(pageNumber),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final ayahs = snapshot.data!;
        if (ayahs.isEmpty) {
          return const Center(
            child: Text('لا توجد آيات تبدأ في هذه الصفحة', style: TextStyle(fontFamily: 'Scheherazade', color: Colors.black45)),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: ayahs.length,
          separatorBuilder: (_, __) => const Divider(height: 24),
          itemBuilder: (context, i) => _AyahBlock(ayah: ayahs[i], mode: mode, tafsirType: settings.tafsirType),
        );
      },
    );
  }
}

class _AyahBlock extends ConsumerWidget {
  final Ayah ayah;
  final StudyMode mode;
  final TafsirType tafsirType;
  const _AyahBlock({required this.ayah, required this.mode, required this.tafsirType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahAsync = ref.watch(surahByNumberProvider(ayah.surah));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: const TextStyle(fontFamily: 'Uthmanic', fontSize: 21, height: 1.9, color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold),
            children: [
              TextSpan(text: ayah.text),
              TextSpan(text: ' (${toEasternArabicDigits(ayah.ayah)}) ', style: const TextStyle(color: Color(0xFFB8860B))),
            ],
          ),
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 6),
        _buildContent(ref, surahAsync.value),
      ],
    );
  }

  Widget _buildContent(WidgetRef ref, Surah? surah) {
    final repo = ref.watch(quranRepositoryProvider);
    switch (mode) {
      case StudyMode.tafsir:
        return FutureBuilder<Tafsir?>(
          future: repo.getTafsir(surah: ayah.surah, ayah: ayah.ayah, type: tafsirType),
          builder: (context, snap) => Text(
            snap.data?.text ?? '...',
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontFamily: 'Scheherazade', fontSize: 15, height: 1.8, color: Colors.black87),
          ),
        );
      case StudyMode.meanings:
        return FutureBuilder(
          future: repo.getWordMeanings(surah: ayah.surah, ayah: ayah.ayah),
          builder: (context, snap) {
            final list = snap.data ?? const [];
            if (list.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final w in list)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: RichText(
                      textDirection: TextDirection.rtl,
                      text: TextSpan(
                        style: const TextStyle(fontFamily: 'Scheherazade', fontSize: 14.5, color: Colors.black87),
                        children: [
                          TextSpan(text: '${w.word} : ', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A))),
                          TextSpan(text: w.meaning),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      case StudyMode.asbab:
        return FutureBuilder(
          future: repo.getAsbabNuzul(ayah.surah, ayah.ayah),
          builder: (context, snap) {
            final asbab = snap.data;
            if (asbab == null) return const SizedBox.shrink();
            return Text(
              asbab.text,
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontFamily: 'Scheherazade', fontSize: 15, height: 1.8, color: Colors.black87),
            );
          },
        );
    }
  }
}
