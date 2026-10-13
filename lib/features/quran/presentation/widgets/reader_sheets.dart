import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/quran_design/quran_design.dart';
import '../../domain/entities/asbab_nuzul.dart';
import '../../domain/entities/ayah.dart';
import '../../domain/entities/surah.dart';
import '../../domain/entities/tafsir.dart';
import '../../domain/entities/word_meaning.dart';
import '../riverpod/quran_providers.dart';

const _kTextFonts = ['Uthmanic', 'Scheherazade'];

// ============================================================
// 1) نافذة "ضبط" — حجم الخط، لون الآية، لون النص، الخط، التجويد
// ============================================================
class QuranSettingsDialog extends ConsumerStatefulWidget {
  const QuranSettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return OrnateDialogFrame.show<void>(
      context,
      title: 'ضبط',
      child: const QuranSettingsDialog(),
    );
  }

  @override
  ConsumerState<QuranSettingsDialog> createState() => _QuranSettingsDialogState();
}

class _QuranSettingsDialogState extends ConsumerState<QuranSettingsDialog> {
  late double _fontSize;
  late Color _verseColor;
  late Color _textColor;
  late String _fontFamily;
  late bool _tajweed;
  late bool _showSilentMark;

  static const _palette = [
    Color(0xFF4A3300), Color(0xFF1B5E20), Color(0xFF0D47A1),
    Color(0xFFB71C1C), Color(0xFF4A148C), Color(0xFF3B3B3B),
    Color(0xFF000000), Color(0xFF6B3F1D),
  ];

  @override
  void initState() {
    super.initState();
    final s = ref.read(quranSettingsProvider);
    _fontSize = s.fontSize;
    _verseColor = Color(s.verseColorValue);
    _textColor = Color(s.textColorValue);
    _fontFamily = s.studyFontFamily;
    _tajweed = s.tajweedEnabled;
    _showSilentMark = s.showSilentMark;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontFamily: _fontFamily, fontSize: _fontSize, color: _verseColor, height: 1.8),
          ),
        ),
        Row(
          children: [
            Text('حجم الخط: ${_fontSize.toStringAsFixed(0)}', style: const TextStyle(fontFamily: 'Scheherazade')),
            Expanded(
              child: Slider(
                value: _fontSize,
                min: 14,
                max: 40,
                activeColor: QuranDesignColors.ribbonTeal,
                onChanged: (v) => setState(() => _fontSize = v),
              ),
            ),
          ],
        ),
        _colorRow('لون آيات القرآن', _verseColor, (c) => setState(() => _verseColor = c)),
        const SizedBox(height: 8),
        _colorRow('لون النص العام', _textColor, (c) => setState(() => _textColor = c)),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text('نوع الخط', style: TextStyle(fontFamily: 'Scheherazade', fontWeight: FontWeight.bold)),
            const Spacer(),
            DropdownButton<String>(
              value: _fontFamily,
              items: _kTextFonts
                  .map((f) => DropdownMenuItem(value: f, child: Text(f, style: TextStyle(fontFamily: f))))
                  .toList(),
              onChanged: (v) => setState(() => _fontFamily = v ?? _fontFamily),
            ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('تلوين أحكام التجويد', style: TextStyle(fontFamily: 'Scheherazade')),
          value: _tajweed,
          activeThumbColor: QuranDesignColors.ribbonTeal,
          onChanged: (v) => setState(() => _tajweed = v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('إظهار علامة الحرف الساكت (دائرة صغيرة ۟)', style: TextStyle(fontFamily: 'Scheherazade')),
          value: _showSilentMark,
          activeThumbColor: QuranDesignColors.ribbonTeal,
          onChanged: (v) => setState(() => _showSilentMark = v),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OrnateButton(label: 'رجوع', color: const Color(0xFFB71C1C), onTap: () => Navigator.pop(context)),
            OrnateButton(
              label: 'حفظ',
              color: QuranDesignColors.ribbonTeal,
              onTap: () {
                ref.read(quranSettingsProvider.notifier).saveStudyAppearance(
                      fontSize: _fontSize,
                      verseColorValue: _verseColor.toARGB32(),
                      textColorValue: _textColor.toARGB32(),
                      fontFamily: _fontFamily,
                      tajweedEnabled: _tajweed,
                      showSilentMark: _showSilentMark,
                    );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _colorRow(String label, Color current, ValueChanged<Color> onPick) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontFamily: 'Scheherazade'))),
        Wrap(
          spacing: 6,
          children: _palette.map((c) {
            final selected = c.toARGB32() == current.toARGB32();
            return GestureDetector(
              onTap: () => onPick(c),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(color: selected ? Colors.white : Colors.black26, width: selected ? 2.4 : 1),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// نافذة صغيرة سريعة لاختيار لون خلفية صفحة المصحف (زر "الخلفية" بالشريط)
class BackgroundPickerDialog extends ConsumerWidget {
  const BackgroundPickerDialog({super.key});

  static Future<void> show(BuildContext context) {
    return OrnateDialogFrame.show<void>(context, title: 'لون الخلفية', child: const BackgroundPickerDialog());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(quranSettingsProvider).pageBackgroundIndex;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (var i = 0; i < QuranDesignColors.pageBackgrounds.length; i++)
          GestureDetector(
            onTap: () {
              ref.read(quranSettingsProvider.notifier).setPageBackground(i);
              Navigator.pop(context);
            },
            child: Column(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: QuranDesignColors.pageBackgrounds[i].value,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: i == current ? QuranDesignColors.ribbonTeal : Colors.black26,
                      width: i == current ? 3 : 1,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(QuranDesignColors.pageBackgrounds[i].key, style: const TextStyle(fontFamily: 'Scheherazade', fontSize: 12)),
              ],
            ),
          ),
      ],
    );
  }
}

// ============================================================
// عنصر مشترك: عرض نص الآية المحددة أعلى أي لفافة (بلون بارز)
// ============================================================
class _SelectedAyahHeader extends StatelessWidget {
  final Ayah ayah;
  final String surahName;
  const _SelectedAyahHeader({required this.ayah, required this.surahName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFB8860B).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFB8860B).withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            ayah.text,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontFamily: 'Uthmanic', fontSize: 20, height: 1.8, color: Color(0xFFB8860B)),
          ),
          const SizedBox(height: 6),
          Text('سورة $surahName - آية ${ayah.ayah}',
              style: const TextStyle(fontFamily: 'Scheherazade', fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }
}

Widget _noSelectionHint(String action) {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: Text(
      'اختر آية من الصفحة أولًا لعرض $action الخاص بها',
      textAlign: TextAlign.center,
      style: const TextStyle(fontFamily: 'Scheherazade', fontSize: 15, color: Colors.black54),
    ),
  );
}

// ============================================================
// 2) معنى الآية
// ============================================================
class WordMeaningsSheetContent extends ConsumerWidget {
  final ScrollController scrollController;
  const WordMeaningsSheetContent({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reader = ref.watch(mushafReaderProvider);
    if (!reader.hasSelection) return _noSelectionHint('معاني كلماتها');

    final repo = ref.watch(quranRepositoryProvider);
    return FutureBuilder<(Ayah?, Surah?, List<WordMeaning>)>(
      future: () async {
        final ayah = await repo.getAyah(reader.selectedSurah!, reader.selectedAyah!);
        final surah = await repo.getSurahByNumber(reader.selectedSurah!);
        final meanings = await repo.getWordMeanings(surah: reader.selectedSurah!, ayah: reader.selectedAyah!);
        return (ayah, surah, meanings);
      }(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final (ayah, surah, meanings) = snapshot.data!;
        if (ayah == null) return const SizedBox.shrink();

        return ListView(
          controller: scrollController,
          children: [
            _SelectedAyahHeader(ayah: ayah, surahName: surah?.name ?? '${ayah.surah}'),
            if (meanings.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('لا توجد كلمات غريبة مسجّلة لهذه الآية.',
                    textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Scheherazade', color: Colors.black54)),
              )
            else
              for (final w in meanings) _meaningRow(w),
          ],
        );
      },
    );
  }

  Widget _meaningRow(WordMeaning w) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: RichText(
        textDirection: TextDirection.rtl,
        text: TextSpan(
          style: const TextStyle(fontFamily: 'Scheherazade', fontSize: 15, color: Colors.black87),
          children: [
            TextSpan(text: '${w.word} : ', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A))),
            TextSpan(text: w.meaning),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 3) التفسير
// ============================================================
class TafsirSheetContent extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  const TafsirSheetContent({super.key, required this.scrollController});

  @override
  ConsumerState<TafsirSheetContent> createState() => _TafsirSheetContentState();
}

class _TafsirSheetContentState extends ConsumerState<TafsirSheetContent> {
  @override
  Widget build(BuildContext context) {
    final reader = ref.watch(mushafReaderProvider);
    if (!reader.hasSelection) return _noSelectionHint('تفسيرها');

    final settings = ref.watch(quranSettingsProvider);
    final repo = ref.watch(quranRepositoryProvider);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _tafsirTab('التفسير الميسر', TafsirType.muyassar, settings.tafsirType),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _tafsirTab('ابن كثير', TafsirType.ibnKathir, settings.tafsirType),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: FutureBuilder<(Ayah?, Surah?, Tafsir?)>(
            future: () async {
              final ayah = await repo.getAyah(reader.selectedSurah!, reader.selectedAyah!);
              final surah = await repo.getSurahByNumber(reader.selectedSurah!);
              final tafsir = await repo.getTafsir(surah: reader.selectedSurah!, ayah: reader.selectedAyah!, type: settings.tafsirType);
              return (ayah, surah, tafsir);
            }(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final (ayah, surah, tafsir) = snapshot.data!;
              if (ayah == null) return const SizedBox.shrink();
              return ListView(
                controller: widget.scrollController,
                children: [
                  _SelectedAyahHeader(ayah: ayah, surahName: surah?.name ?? '${ayah.surah}'),
                  Text(
                    tafsir?.text ?? 'لم يُعثر على تفسير لهذه الآية.',
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontFamily: 'Scheherazade', fontSize: 15, height: 1.9),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _tafsirTab(String label, TafsirType type, TafsirType current) {
    final selected = type == current;
    return Material(
      color: selected ? QuranDesignColors.ribbonTeal : Colors.white.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => ref.read(quranSettingsProvider.notifier).setTafsirType(type),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Scheherazade',
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 4) سبب النزول
// ============================================================
class AsbabNuzulSheetContent extends ConsumerWidget {
  final ScrollController scrollController;
  const AsbabNuzulSheetContent({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reader = ref.watch(mushafReaderProvider);
    if (!reader.hasSelection) return _noSelectionHint('سبب نزولها');

    final repo = ref.watch(quranRepositoryProvider);
    return FutureBuilder<(Ayah?, Surah?, AsbabNuzul?)>(
      future: () async {
        final ayah = await repo.getAyah(reader.selectedSurah!, reader.selectedAyah!);
        final surah = await repo.getSurahByNumber(reader.selectedSurah!);
        final asbab = await repo.getAsbabNuzul(reader.selectedSurah!, reader.selectedAyah!);
        return (ayah, surah, asbab);
      }(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final (ayah, surah, asbab) = snapshot.data!;
        if (ayah == null) return const SizedBox.shrink();

        return ListView(
          controller: scrollController,
          children: [
            _SelectedAyahHeader(ayah: ayah, surahName: surah?.name ?? '${ayah.surah}'),
            Text(
              asbab?.text ?? 'لم يرد في مصادرنا سببُ نزولٍ مأثور خاص بهذه الآية تحديدًا.',
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontFamily: 'Scheherazade', fontSize: 15, height: 1.9),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// 5) دعاء ختم القرآن (نص ثابت)
// ============================================================
const String khatmDua = '''
اللهم ارحمنا بالقرآن، واجعله لنا إمامًا ونورًا وهدى ورحمة،
اللهم ذكّرنا منه ما نُسّينا، وعلّمنا منه ما جهلنا،
وارزقنا تلاوته آناء الليل وأطراف النهار، واجعله لنا حجّة يا رب العالمين.
اللهم اجعل القرآن العظيم ربيع قلوبنا، ونور صدورنا، وجلاء أحزاننا، وذهاب همومنا وغمومنا.
آمين.
''';

class KhatmDuaSheetContent extends StatelessWidget {
  final ScrollController scrollController;
  const KhatmDuaSheetContent({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      children: const [
        Text(
          khatmDua,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: TextStyle(fontFamily: 'Scheherazade', fontSize: 17, height: 2.0),
        ),
      ],
    );
  }
}

// ============================================================
// 6) البحث
// ============================================================
class SearchSheetContent extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final void Function(int surah, int ayah) onResultTap;
  const SearchSheetContent({super.key, required this.scrollController, required this.onResultTap});

  @override
  ConsumerState<SearchSheetContent> createState() => _SearchSheetContentState();
}

class _SearchSheetContentState extends ConsumerState<SearchSheetContent> {
  final _controller = TextEditingController();
  List<Ayah> _results = [];
  Map<int, Surah> _surahs = {};
  bool _searched = false;

  Future<void> _search(String q) async {
    final repo = ref.read(quranRepositoryProvider);
    if (_surahs.isEmpty) {
      final list = await repo.getSurahList();
      _surahs = {for (final s in list) s.number: s};
    }
    if (q.trim().isEmpty) {
      setState(() {
        _results = [];
        _searched = false;
      });
      return;
    }
    final results = await repo.searchInQuran(q);
    if (mounted) {
      setState(() {
        _results = results;
        _searched = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          textDirection: TextDirection.rtl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'ابحث في آيات القرآن...',
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.6),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
          onSubmitted: _search,
        ),
        const SizedBox(height: 8),
        if (_searched)
          Align(
            alignment: Alignment.centerRight,
            child: Text('عدد الآيات: ${_results.length}', style: const TextStyle(fontFamily: 'Scheherazade', fontWeight: FontWeight.bold)),
          ),
        Expanded(
          child: !_searched
              ? const SizedBox.shrink()
              : ListView.separated(
                  controller: widget.scrollController,
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, i) {
                    final a = _results[i];
                    final surah = _surahs[a.surah];
                    return InkWell(
                      onTap: () => widget.onResultTap(a.surah, a.ayah),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(a.text, textDirection: TextDirection.rtl, textAlign: TextAlign.center,
                                style: const TextStyle(fontFamily: 'Uthmanic', fontSize: 18, height: 1.7)),
                            const SizedBox(height: 4),
                            Text('${surah?.name ?? a.surah} - آية ${a.ayah}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontFamily: 'Scheherazade', fontSize: 12, color: Colors.black54)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ============================================================
// 7) الفهرس (السور / الأجزاء)
// ============================================================
class FihrisSheetContent extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final void Function(int surah, int ayah) onSurahTap;
  final void Function(int page) onJuzTap;

  const FihrisSheetContent({
    super.key,
    required this.scrollController,
    required this.onSurahTap,
    required this.onJuzTap,
  });

  @override
  ConsumerState<FihrisSheetContent> createState() => _FihrisSheetContentState();
}

class _FihrisSheetContentState extends ConsumerState<FihrisSheetContent> {
  bool _showSurahs = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _tab('فهرس الأجزاء', !_showSurahs, () => setState(() => _showSurahs = false))),
            const SizedBox(width: 8),
            Expanded(child: _tab('فهرس السور', _showSurahs, () => setState(() => _showSurahs = true))),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(child: _showSurahs ? _buildSurahList() : _buildJuzList()),
      ],
    );
  }

  Widget _tab(String label, bool selected, VoidCallback onTap) {
    return Material(
      color: selected ? QuranDesignColors.ribbonTeal : Colors.white.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(label, textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Scheherazade', fontWeight: FontWeight.bold, color: selected ? Colors.white : Colors.black87)),
        ),
      ),
    );
  }

  Widget _buildSurahList() {
    final surahsAsync = ref.watch(surahListProvider);
    return surahsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (surahs) => ListView.separated(
        controller: widget.scrollController,
        itemCount: surahs.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final s = surahs[i];
          return ListTile(
            onTap: () => widget.onSurahTap(s.number, 1),
            leading: Text('${s.ayahCount}', style: const TextStyle(fontFamily: 'Scheherazade')),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${s.number}', style: const TextStyle(fontFamily: 'Scheherazade', color: Colors.black45)),
                const SizedBox(width: 8),
                s.isMeccan ? const KaabaIcon(size: 18) : const MedinanDomeIcon(size: 18),
              ],
            ),
            title: Text(s.name, textAlign: TextAlign.right, style: const TextStyle(fontFamily: 'Scheherazade', fontWeight: FontWeight.bold)),
          );
        },
      ),
    );
  }

  Widget _buildJuzList() {
    final pagesAsync = ref.watch(juzStartPagesProvider);
    return pagesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (pages) => ListView.separated(
        controller: widget.scrollController,
        itemCount: pages.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) => ListTile(
          onTap: () => widget.onJuzTap(pages[i]),
          title: Text('الجزء ${toEasternArabicDigits(i + 1)}', textAlign: TextAlign.right, style: const TextStyle(fontFamily: 'Scheherazade', fontWeight: FontWeight.bold)),
          trailing: Text('صفحة ${toEasternArabicDigits(pages[i])}', style: const TextStyle(fontFamily: 'Scheherazade', color: Colors.black54)),
        ),
      ),
    );
  }
}

// ============================================================
// أدوات نسخ/مشاركة مشتركة
// ============================================================
void copyAyahToClipboard(BuildContext context, Ayah ayah) {
  Clipboard.setData(ClipboardData(text: ayah.text));
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('تم نسخ الآية', style: TextStyle(fontFamily: 'Scheherazade')), duration: Duration(seconds: 2)),
  );
}

void copyPageToClipboard(BuildContext context, List<Ayah> ayahs) {
  Clipboard.setData(ClipboardData(text: ayahs.map((a) => a.text).join(' ')));
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('تم نسخ نص الصفحة', style: TextStyle(fontFamily: 'Scheherazade')), duration: Duration(seconds: 2)),
  );
}

/// مشاركة نص الآية بصيغة اقتباس جميلة عبر نظام مشاركة الجهاز الحقيقي
/// (أي تطبيق تواصل مثبَّت)، بالشكل: قال تعالى: ﴿ النص ﴾ [سورة س: رقم]
Future<void> shareAyahText(BuildContext context, Ayah ayah, String surahName) async {
  final formatted =
      'قال تعالى: ﴿ ${ayah.text} ﴾\n\n[سورة $surahName - الآية ${toEasternArabicDigits(ayah.ayah)}]';
  await SharePlus.instance.share(ShareParams(text: formatted, subject: 'آية من القرآن الكريم'));
}

/// مشاركة صورة فعلية لصفحة المصحف الحالية (التقاط لقطة من الواجهة نفسها)
Future<void> sharePageImage(BuildContext context, GlobalKey boundaryKey) async {
  try {
    final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) throw StateError('تعذّر العثور على الصفحة لالتقاطها');
    final image = await boundary.toImage(pixelRatio: 2.5);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) throw StateError('تعذّر تحويل الصفحة إلى صورة');
    final bytes = byteData.buffer.asUint8List();
    await SharePlus.instance.share(ShareParams(
      files: [XFile.fromData(bytes, mimeType: 'image/png')],
      fileNameOverrides: const ['quran_page.png'],
      subject: 'صفحة من القرآن الكريم',
    ));
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذّرت مشاركة الصورة: $e', style: const TextStyle(fontFamily: 'Scheherazade'))),
      );
    }
  }
}
