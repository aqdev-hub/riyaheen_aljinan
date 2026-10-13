import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/quran_design/quran_design.dart';
import '../../domain/entities/ayah.dart';
import '../../domain/entities/mushaf_line.dart';
import '../../domain/entities/tajweed_annotation.dart';
import '../riverpod/quran_providers.dart';
import 'tajweed_text.dart';

/// مقطع نصي (كلمة أو كلمة + علامة وقف) بإزاحات أحرفه داخل نص الآية
class _Tok {
  final int start;
  final int end;
  const _Tok(this.start, this.end);
}

/// عنصر واحد داخل السطر: كلمة أو شارة رقم آية
class _Item {
  final int surah;
  final int ayah;
  final String text;
  final List<TajweedAnnotation> annotations;
  final bool isBadge;
  const _Item({
    required this.surah,
    required this.ayah,
    this.text = '',
    this.annotations = const [],
    this.isBadge = false,
  });
}

class _PreparedLine {
  final MushafLine line;
  final List<_Item> items;
  const _PreparedLine(this.line, this.items);
}

class _Seg {
  final int surah;
  final int ayah;
  final int start;
  int end;
  _Seg(this.surah, this.ayah, this.start, this.end);
}

/// صفحة واحدة من المصحف (604 صفحة). كل سطر يُوزَّع كلماته على كامل العرض
/// (ضبط الهوامش كالمصحف المطبوع)، وحجم الخط يُحسب لكل صفحة بحيث يتسع أعرض
/// سطر فيها. محتوى الصفحة (أي آية في أي سطر) مطابق لتخطيط مصحف المدينة.
class MushafPageView extends ConsumerStatefulWidget {
  final int pageNumber;
  final MushafPageContent content;

  const MushafPageView({super.key, required this.pageNumber, required this.content});

  @override
  ConsumerState<MushafPageView> createState() => _MushafPageViewState();
}

class _MushafPageViewState extends ConsumerState<MushafPageView> {
  static const double _refSize = 30;
  static const double _gapFactor = 0.16;
  static const double _centeredGapFactor = 0.3;
  static const double _badgeFactor = 1.25;
  static const int _silentMark = 0x06DF; // ۟ دائرة صغيرة فوق الحرف الساكت

  List<_PreparedLine>? _prepared;
  Map<int, String> _surahNames = {};
  final Map<String, List<_Tok>> _tokCache = {};

  String? _fitKey;
  double _fitSize = 22;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(quranRepositoryProvider);
    final ayahs = <String, Ayah>{};
    final counts = <int, Map<int, int>>{};

    for (final line in widget.content.lines) {
      for (final w in line.words) {
        final key = '${w.surah}:${w.ayah}';
        if (!ayahs.containsKey(key)) {
          final a = await repo.getAyah(w.surah, w.ayah);
          if (a != null) ayahs[key] = a;
        }
        if (!counts.containsKey(w.surah)) {
          counts[w.surah] = await repo.getWordCountsForSurah(w.surah);
        }
      }
    }

    final surahs = await repo.getSurahList();
    final names = {for (final s in surahs) s.number: s.name};
    final basmala = await repo.getAyah(1, 1);

    final prepared = <_PreparedLine>[];
    for (final line in widget.content.lines) {
      switch (line.type) {
        case MushafLineType.surahName:
          prepared.add(_PreparedLine(line, const []));
          break;
        case MushafLineType.basmallah:
          if (basmala != null) {
            final toks = _tokens(basmala);
            prepared.add(_PreparedLine(line, [
              for (final t in toks) _wordItem(basmala, t),
            ]));
          } else {
            prepared.add(_PreparedLine(line, const []));
          }
          break;
        case MushafLineType.ayah:
          prepared.add(_PreparedLine(line, _itemsForLine(line, ayahs, counts)));
          break;
      }
    }

    if (!mounted) return;
    setState(() {
      _prepared = prepared;
      _surahNames = names;
    });
  }

  // ========================================
  // تجهيز عناصر السطر
  // ========================================
  List<_Item> _itemsForLine(MushafLine line, Map<String, Ayah> ayahs, Map<int, Map<int, int>> counts) {
    final segs = <_Seg>[];
    for (final w in line.words) {
      final last = segs.isEmpty ? null : segs.last;
      if (last != null && last.surah == w.surah && last.ayah == w.ayah && last.end == w.wordPosition - 1) {
        last.end = w.wordPosition;
      } else {
        segs.add(_Seg(w.surah, w.ayah, w.wordPosition, w.wordPosition));
      }
    }

    final items = <_Item>[];
    for (final seg in segs) {
      final ayah = ayahs['${seg.surah}:${seg.ayah}'];
      final total = counts[seg.surah]?[seg.ayah];
      if (ayah == null || total == null) continue;

      // آخر موضع في ملف المصحف هو رمز نهاية الآية (ليس كلمة نصية)
      final realWords = total - 1;
      final realEnd = math.min(seg.end, realWords);
      if (realWords > 0 && seg.start <= realEnd) {
        final toks = _tokens(ayah);
        int from;
        int to;
        if (toks.length == realWords) {
          from = seg.start - 1;
          to = realEnd;
        } else {
          // اختلاف نادر في تقطيع الكلمات: نوزّع نسبيًا كي لا يضيع أي نص
          from = ((seg.start - 1) * toks.length / realWords).round();
          to = (realEnd * toks.length / realWords).round();
        }
        from = from.clamp(0, toks.length);
        to = to.clamp(0, toks.length);
        for (var i = from; i < to; i++) {
          items.add(_wordItem(ayah, toks[i]));
        }
      }
      if (seg.end >= total) {
        items.add(_Item(surah: seg.surah, ayah: seg.ayah, isBadge: true));
      }
    }
    return items;
  }

  _Item _wordItem(Ayah ayah, _Tok t) {
    final anns = <TajweedAnnotation>[];
    for (final a in ayah.tajweed) {
      if (a.start < t.end && a.end > t.start) {
        anns.add(TajweedAnnotation(
          start: math.max(a.start, t.start) - t.start,
          end: math.min(a.end, t.end) - t.start,
          rule: a.rule,
        ));
      }
    }
    return _Item(
      surah: ayah.surah,
      ayah: ayah.ayah,
      text: ayah.text.substring(t.start, t.end),
      annotations: anns,
    );
  }

  List<_Tok> _tokens(Ayah ayah) {
    return _tokCache.putIfAbsent('${ayah.surah}:${ayah.ayah}', () => _tokenize(ayah.text));
  }

  static bool _isMarkOnly(String piece) {
    for (final r in piece.runes) {
      final ok = (r >= 0x06D6 && r <= 0x06ED) ||
          (r >= 0x0610 && r <= 0x061A) ||
          (r >= 0x064B && r <= 0x065F) ||
          r == 0x0670 ||
          r == 0x0640;
      if (!ok) return false;
    }
    return piece.isNotEmpty;
  }

  /// يقسّم النص إلى كلمات، ويُلحق علامات الوقف المنفردة بالكلمة السابقة
  /// (وعلامة الحزب ۞ بالكلمة التالية)، ليطابق ترقيم كلمات ملف المصحف
  static List<_Tok> _tokenize(String text) {
    final toks = <_Tok>[];
    int? pendingStart;
    var i = 0;
    final n = text.length;
    while (i < n) {
      while (i < n && text[i] == ' ') {
        i++;
      }
      if (i >= n) break;
      var j = i;
      while (j < n && text[j] != ' ') {
        j++;
      }
      final piece = text.substring(i, j);
      if (_isMarkOnly(piece)) {
        if (toks.isNotEmpty) {
          toks[toks.length - 1] = _Tok(toks.last.start, j);
        } else {
          pendingStart ??= i;
        }
      } else {
        toks.add(_Tok(pendingStart ?? i, j));
        pendingStart = null;
      }
      i = j;
    }
    return toks;
  }

  // ========================================
  // قياس حجم الخط المناسب لعرض الصفحة
  // ========================================
  /// يحوّل عنصر كلمة إلى ما سيُعرض فعلًا: عند إخفاء علامة الحرف الساكت (۟)
  /// تُحذف من النص وتُعاد مواءمة فهارس أحكام التجويد معه
  _Item _displayItem(_Item it, bool showMark) {
    if (showMark || it.isBadge || !it.text.runes.contains(_silentMark)) return it;
    final sb = StringBuffer();
    final map = List<int>.filled(it.text.length + 1, 0); // الفهرس القديم → الجديد
    var newIdx = 0;
    for (var i = 0; i < it.text.length; i++) {
      map[i] = newIdx;
      final cu = it.text.codeUnitAt(i);
      if (cu == _silentMark) continue;
      sb.writeCharCode(cu);
      newIdx++;
    }
    map[it.text.length] = newIdx;

    final anns = <TajweedAnnotation>[];
    for (final a in it.annotations) {
      final st = map[a.start.clamp(0, it.text.length)];
      final en = map[a.end.clamp(0, it.text.length)];
      if (en > st) anns.add(TajweedAnnotation(start: st, end: en, rule: a.rule));
    }
    return _Item(surah: it.surah, ayah: it.ayah, text: sb.toString(), annotations: anns);
  }

  /// أكبر حجم خط يتسع معه أعرض سطر في الصفحة (يشمل الأسطر المتوسّطة
  /// والبسملة) — هذا ما كان ناقصًا فيسبب تجاوز العرض في الصفحتين 1 و2
  double _fitFontSize(double width, double slotHeight, bool showMark) {
    final key = '${width.toStringAsFixed(1)}|${slotHeight.toStringAsFixed(1)}|$showMark';
    if (_fitKey == key) return _fitSize;

    var best = slotHeight * 0.62;
    for (final pl in _prepared!) {
      if (pl.line.type == MushafLineType.surahName) continue;
      var tokenSum = 0.0;
      var badges = 0;
      var count = 0;
      for (final raw in pl.items) {
        count++;
        if (raw.isBadge) {
          badges++;
          continue;
        }
        final it = _displayItem(raw, showMark);
        final tp = TextPainter(
          text: TextSpan(text: it.text, style: const TextStyle(fontFamily: 'Uthmanic', fontSize: _refSize)),
          textDirection: TextDirection.rtl,
        )..layout();
        tokenSum += tp.width;
      }
      if (count == 0) continue;
      final gap = pl.line.isCentered ? _centeredGapFactor : _gapFactor;
      final denom = tokenSum / _refSize + _badgeFactor * badges + gap * (count - 1);
      final avail = width - AyahRosetteBadge.badgeHorizontalPadding * badges;
      if (denom > 0) best = math.min(best, avail / denom * 0.97);
    }

    _fitKey = key;
    _fitSize = best.clamp(12.0, 40.0);
    return _fitSize;
  }

  // ========================================
  // البناء
  // ========================================
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(quranSettingsProvider);
    final reader = ref.watch(mushafReaderProvider);
    final bgIndex = settings.pageBackgroundIndex.clamp(0, QuranDesignColors.pageBackgrounds.length - 1);
    final bg = QuranDesignColors.pageBackgrounds[bgIndex].value;

    if (_prepared == null) {
      return Container(color: bg, child: const Center(child: CircularProgressIndicator()));
    }

    final slots = widget.pageNumber <= 2 ? 8 : 15;

    // صفحة المصحف بتخطيط ثابت: لا نسمح لتكبير خط النظام بتوسيع الكلمات
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final slotH = constraints.maxHeight / slots;
          final fontSize = _fitFontSize(constraints.maxWidth, slotH, settings.showSilentMark);
          final byNumber = {for (final pl in _prepared!) pl.line.lineNumber: pl};

          return Column(
            children: [
              for (var n = 1; n <= slots; n++)
                SizedBox(
                  height: slotH,
                  child: byNumber[n] == null
                      ? const SizedBox.shrink()
                      : _buildLine(byNumber[n]!, fontSize, slotH, settings, reader),
                ),
            ],
          );
        },
      ),
    ),
    );
  }

  Widget _buildLine(
    _PreparedLine pl,
    double fontSize,
    double slotH,
    QuranSettingsState settings,
    MushafReaderState reader,
  ) {
    switch (pl.line.type) {
      case MushafLineType.surahName:
        return Center(
          child: SizedBox(
            height: slotH * 0.86,
            child: SurahNameBanner(surahName: _surahNames[pl.line.surahNumber] ?? ''),
          ),
        );
      case MushafLineType.basmallah:
      case MushafLineType.ayah:
        return _buildTextLine(pl, fontSize, settings, reader);
    }
  }

  Widget _buildTextLine(
    _PreparedLine pl,
    double fontSize,
    QuranSettingsState settings,
    MushafReaderState reader,
  ) {
    final style = TextStyle(
      fontFamily: 'Uthmanic',
      fontSize: fontSize,
      height: 1.3,
      color: const Color(0xFF1A1A1A),
    );

    final children = <Widget>[];
    for (final raw in pl.items) {
      final it = _displayItem(raw, settings.showSilentMark);
      final selected = reader.selectedSurah == it.surah && reader.selectedAyah == it.ayah;
      final Widget child;
      if (it.isBadge) {
        child = AyahRosetteBadge(
          number: it.ayah,
          size: fontSize * _badgeFactor,
          isBookmarked: settings.isBookmarked(it.surah, it.ayah),
          isSelected: selected,
        );
      } else {
        child = Text.rich(
          TextSpan(
            style: style,
            children: TajweedText.buildSpans(
              text: it.text,
              annotations: it.annotations,
              style: style,
              enabled: settings.tajweedEnabled,
            ),
          ),
          textDirection: TextDirection.rtl,
          maxLines: 1,
          softWrap: false,
        );
      }

      children.add(GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          final notifier = ref.read(mushafReaderProvider.notifier);
          if (ref.read(mushafReaderProvider).toolbarVisible) {
            notifier.dismissToolbar(); // أي ضغطة خارج الشريط تغلقه
          } else {
            notifier.selectAyah(it.surah, it.ayah);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: selected && !it.isBadge ? const Color(0x33FFB300) : Colors.transparent,
            borderRadius: BorderRadius.circular(3),
          ),
          child: child,
        ),
      ));
    }

    final centered = pl.line.isCentered;
    final row = Row(
      textDirection: TextDirection.rtl,
      mainAxisAlignment: centered ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: centered
          ? [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(width: fontSize * _centeredGapFactor),
                children[i],
              ],
            ]
          : children,
    );

    // شبكة أمان: لو زاد عرض السطر لأي سبب (خط/جهاز مختلف) يُصغَّر ليتسع
    // بدل ظهور شريط تجاوز العرض الأصفر والأسود
    return LayoutBuilder(
      builder: (context, c) => FittedBox(
        fit: BoxFit.scaleDown,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: c.maxWidth),
          child: row,
        ),
      ),
    );
  }
}
