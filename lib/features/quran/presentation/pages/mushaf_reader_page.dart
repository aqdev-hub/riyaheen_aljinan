import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/quran_design/quran_design.dart';
import '../riverpod/quran_providers.dart';
import '../widgets/mushaf_page_view.dart';
import '../widgets/reader_sheets.dart';

/// أفعال يمكن فتحها تلقائيًا عند دخول القارئ (قادمة من قائمة الاختيار
/// الأولى: القرآن مطبوع / التفسير / معاني الكلمات / سبب النزول)
enum MushafInitialAction { none, tafsir, meanings, asbab }

class MushafReaderPage extends ConsumerStatefulWidget {
  final int? surahNumber;
  final int? ayahNumber;
  final int? initialPage;
  final MushafInitialAction initialAction;

  const MushafReaderPage({
    super.key,
    this.surahNumber,
    this.ayahNumber,
    this.initialPage,
    this.initialAction = MushafInitialAction.none,
  });

  @override
  ConsumerState<MushafReaderPage> createState() => _MushafReaderPageState();
}

class _MushafReaderPageState extends ConsumerState<MushafReaderPage> {
  final GlobalKey _pageBoundaryKey = GlobalKey();
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final repo = ref.read(quranRepositoryProvider);
    var page = widget.initialPage ?? 1;
    final s = widget.surahNumber;
    final a = widget.ayahNumber ?? 1;

    if (widget.initialPage == null && s != null) {
      page = await repo.getPageNumberForAyah(s, a);
    }
    if (s != null) {
      ref.read(mushafReaderProvider.notifier).selectAyah(s, a, showToolbar: false);
    }

    if (!mounted) return;
    setState(() {
      _pageController = PageController(initialPage: page - 1);
    });

    ref.read(mushafReaderProvider.notifier).setPage(page);

    if (widget.initialAction != MushafInitialAction.none && s != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openAction(widget.initialAction));
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  void _openAction(MushafInitialAction action) {
    switch (action) {
      case MushafInitialAction.tafsir:
        _openSheet('التفسير', (c, ctl) => TafsirSheetContent(scrollController: ctl));
        break;
      case MushafInitialAction.meanings:
        _openSheet('معاني الكلمات', (c, ctl) => WordMeaningsSheetContent(scrollController: ctl));
        break;
      case MushafInitialAction.asbab:
        _openSheet('سبب النزول', (c, ctl) => AsbabNuzulSheetContent(scrollController: ctl));
        break;
      case MushafInitialAction.none:
        break;
    }
  }

  void _openSheet(String title, Widget Function(BuildContext, ScrollController) builder) {
    OrnateScrollSheet.show(context, title: title, builder: builder);
  }

  void _jumpTo(int page, {int? surah, int? ayah}) {
    _pageController?.jumpToPage((page - 1).clamp(0, 603));
    ref.read(mushafReaderProvider.notifier).setPage(page);
    if (surah != null && ayah != null) {
      ref.read(mushafReaderProvider.notifier).selectAyah(surah, ayah, showToolbar: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _pageController;
    if (controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final reader = ref.watch(mushafReaderProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Stack(
                children: [
                  RepaintBoundary(
                    key: _pageBoundaryKey,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        final notifier = ref.read(mushafReaderProvider.notifier);
                        if (ref.read(mushafReaderProvider).toolbarVisible) {
                          notifier.dismissToolbar(); // ضغطة خارج الشريط تغلقه
                        } else {
                          notifier.toggleToolbar();
                        }
                      },
                      child: PageView.builder(
                        controller: controller,
                        itemCount: 604,
                        onPageChanged: _onPageChanged,
                        itemBuilder: (context, index) {
                          final pageNumber = index + 1;
                          final pageAsync = ref.watch(mushafPageProvider(pageNumber));
                          return pageAsync.when(
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (e, _) => Center(child: Text('$e')),
                            data: (content) => MushafPageView(pageNumber: pageNumber, content: content),
                          );
                        },
                      ),
                    ),
                  ),
                  // الشريط طبقة فوق الصفحة (لا يغيّر مقاسها فلا يتبدّل حجم الخط)
                  if (reader.toolbarVisible)
                    Positioned(left: 0, right: 0, bottom: 0, child: _buildToolbar(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPageChanged(int index) {
    final pageNumber = index + 1;
    ref.read(mushafReaderProvider.notifier).setPage(pageNumber);
    ref.read(quranRepositoryProvider).getMushafPage(pageNumber).then((content) {
      for (final line in content.lines) {
        if (line.words.isNotEmpty) {
          final first = line.words.first;
          ref.read(quranSettingsProvider.notifier).setLastRead(first.surah, first.ayah);
          break;
        }
      }
    });
  }

  Widget _buildHeader(BuildContext context) {
    final reader = ref.watch(mushafReaderProvider);
    final pageAsync = ref.watch(mushafPageProvider(reader.currentPage));
    final surahNumber = pageAsync.value?.lines
        .firstWhere((l) => l.words.isNotEmpty, orElse: () => pageAsync.value!.lines.first)
        .words
        .firstOrNull
        ?.surah;

    return Container(
      color: const Color(0xFF4A1F6B),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
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
          Text(toEasternArabicDigits(reader.currentPage), style: const TextStyle(fontFamily: 'Scheherazade', color: Colors.white)),
          const Spacer(),
          if (surahNumber != null)
            Consumer(builder: (context, ref, __) {
              final surahAsync = ref.watch(surahByNumberProvider(surahNumber));
              return Text(
                surahAsync.value != null ? 'سورة ${surahAsync.value!.name}' : '',
                style: const TextStyle(fontFamily: 'Scheherazade', fontWeight: FontWeight.bold, color: Colors.white),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    final items = <_ToolbarIcon>[
      _ToolbarIcon(Icons.palette_rounded, 'الخلفية', () => BackgroundPickerDialog.show(context)),
      _ToolbarIcon(Icons.bookmark_add_rounded, 'حفظ علامة', _saveBookmark),
      _ToolbarIcon(Icons.bookmarks_rounded, 'ذهاب للعلامة', _goToBookmark),
      _ToolbarIcon(Icons.search_rounded, 'بحث', () => _openSheet(
          'بحث', (sheetContext, ctl) => SearchSheetContent(scrollController: ctl, onResultTap: (s, a) async {
                Navigator.of(sheetContext).pop();
                await _jumpToSurah(s, a);
              }))),
      _ToolbarIcon(Icons.menu_book_rounded, 'الفهرس', () => _openSheet(
          'الفهرس', (sheetContext, ctl) => FihrisSheetContent(
                scrollController: ctl,
                onSurahTap: (s, a) {
                  Navigator.of(sheetContext).pop();
                  _jumpToSurah(s, a);
                },
                onJuzTap: (p) {
                  Navigator.of(sheetContext).pop();
                  _jumpTo(p);
                },
              ))),
      _ToolbarIcon(Icons.favorite_rounded, 'دعاء الختام', () => _openSheet('دعاء الختام', (c, ctl) => KhatmDuaSheetContent(scrollController: ctl))),
      _ToolbarIcon(Icons.translate_rounded, 'معنى الآية', () => _openSheet('معاني الكلمات', (c, ctl) => WordMeaningsSheetContent(scrollController: ctl))),
      _ToolbarIcon(Icons.auto_stories_rounded, 'سبب النزول', () => _openSheet('سبب النزول', (c, ctl) => AsbabNuzulSheetContent(scrollController: ctl))),
      _ToolbarIcon(Icons.menu_book_outlined, 'تفسير', () => _openSheet('التفسير', (c, ctl) => TafsirSheetContent(scrollController: ctl))),
      _ToolbarIcon(Icons.tune_rounded, 'الإعدادات', () => QuranSettingsDialog.show(context)),
      _ToolbarIcon(Icons.close_rounded, 'إغلاق', () => ref.read(mushafReaderProvider.notifier).dismissToolbar()),
      _ToolbarIcon(Icons.copy_rounded, 'نسخ الآية', _copySelectedAyah),
      _ToolbarIcon(Icons.description_rounded, 'نسخ الصفحة', _copyPage),
      _ToolbarIcon(Icons.share_rounded, 'مشاركة نص', _shareSelectedAyah),
      _ToolbarIcon(Icons.image_rounded, 'مشاركة صورة', _sharePageImage),
    ];

    return Container(
      color: const Color(0xFF2E1F3B),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      child: GridView.count(
        crossAxisCount: 5,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.05,
        children: [for (final it in items) _toolbarButton(it)],
      ),
    );
  }

  Widget _toolbarButton(_ToolbarIcon item) {
    return InkWell(
      onTap: item.onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: const Color(0xFFD4A843), size: 22),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(item.label, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Scheherazade', fontSize: 10, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _jumpToSurah(int s, int a) async {
    final p = await ref.read(quranRepositoryProvider).getPageNumberForAyah(s, a);
    _jumpTo(p, surah: s, ayah: a);
  }

  void _saveBookmark() {
    final reader = ref.read(mushafReaderProvider);
    if (reader.hasSelection) {
      ref.read(quranSettingsProvider.notifier).toggleBookmark(reader.selectedSurah!, reader.selectedAyah!);
    }
  }

  void _goToBookmark() {
    final list = ref.read(quranSettingsProvider).bookmarksList;
    if (list.isEmpty) return;
    final (s, a) = list.first;
    _jumpToSurah(s, a);
  }

  void _copySelectedAyah() async {
    final reader = ref.read(mushafReaderProvider);
    if (!reader.hasSelection) return;
    final ayah = await ref.read(quranRepositoryProvider).getAyah(reader.selectedSurah!, reader.selectedAyah!);
    if (ayah != null && mounted) copyAyahToClipboard(context, ayah);
  }

  /// يُزيل التظليل والشريط أولًا ثم يلتقط الصفحة نظيفة ويشاركها
  Future<void> _sharePageImage() async {
    ref.read(mushafReaderProvider.notifier).dismissToolbar();
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    await sharePageImage(context, _pageBoundaryKey);
  }

  void _shareSelectedAyah() async {
    final reader = ref.read(mushafReaderProvider);
    if (!reader.hasSelection) return;
    final repo = ref.read(quranRepositoryProvider);
    final ayah = await repo.getAyah(reader.selectedSurah!, reader.selectedAyah!);
    final surah = await repo.getSurahByNumber(reader.selectedSurah!);
    if (ayah != null && mounted) await shareAyahText(context, ayah, surah?.name ?? '${ayah.surah}');
  }

  void _copyPage() async {
    final content = await ref.read(quranRepositoryProvider).getMushafPage(ref.read(mushafReaderProvider).currentPage);
    final repo = ref.read(quranRepositoryProvider);
    final seen = <String>{};
    final ayahs = <dynamic>[];
    for (final line in content.lines) {
      for (final w in line.words) {
        final key = '${w.surah}:${w.ayah}';
        if (seen.add(key)) {
          final a = await repo.getAyah(w.surah, w.ayah);
          if (a != null) ayahs.add(a);
        }
      }
    }
    if (mounted) copyPageToClipboard(context, ayahs.cast());
  }
}

class _ToolbarIcon {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ToolbarIcon(this.icon, this.label, this.onTap);
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
