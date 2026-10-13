import 'dart:convert';

import '../../domain/entities/asbab_nuzul.dart';
import '../../domain/entities/ayah.dart';
import '../../domain/entities/mushaf_line.dart';
import '../../domain/entities/surah.dart';
import '../../domain/entities/tafsir.dart';
import '../../domain/entities/tajweed_annotation.dart';
import '../../domain/entities/word_meaning.dart';
import '../../domain/repositories/quran_repository.dart';
import '../datasources/quran_local_data_source.dart';

/// التنفيذ الفعلي لمستودع القرآن: يحوّل صفوف SQLite الخام إلى كيانات Domain،
/// ويطبّق منطق العمل (تطبيع البحث العربي، التخزين المؤقت في الذاكرة).
class QuranRepositoryImpl implements QuranRepository {
  final QuranLocalDataSource _ds;
  QuranRepositoryImpl(this._ds);

  @override
  final int totalPages = 604;

  // ===== تخزين مؤقت بسيط في الذاكرة =====
  List<Surah>? _surahCache;
  final Map<int, List<Ayah>> _ayahsBySurahCache = {};
  final Map<String, Ayah> _ayahCache = {}; // key: "surah:ayah"
  final Map<int, Map<int, int>> _wordCountCache = {};
  List<Map<String, dynamic>>? _allAyahRowsCache;

  @override
  Future<List<Surah>> getSurahList() async {
    if (_surahCache != null) return _surahCache!;
    final rows = await _ds.getAllSurahRows();
    _surahCache = rows.map(Surah.fromMap).toList();
    return _surahCache!;
  }

  @override
  Future<Surah?> getSurahByNumber(int number) async {
    final list = await getSurahList();
    for (final s in list) {
      if (s.number == number) return s;
    }
    return null;
  }

  @override
  Future<List<Ayah>> getAyahsForSurah(int surahNumber) async {
    if (_ayahsBySurahCache.containsKey(surahNumber)) {
      return _ayahsBySurahCache[surahNumber]!;
    }
    final rows = await _ds.getAyahRowsForSurah(surahNumber);
    final result = <Ayah>[];
    for (final row in rows) {
      result.add(await _buildAyah(row));
    }
    _ayahsBySurahCache[surahNumber] = result;
    return result;
  }

  @override
  Future<Ayah?> getAyah(int surahNumber, int ayahNumber) async {
    final key = '$surahNumber:$ayahNumber';
    if (_ayahCache.containsKey(key)) return _ayahCache[key];
    final row = await _ds.getAyahRow(surahNumber, ayahNumber);
    if (row == null) return null;
    return _buildAyah(row);
  }

  Future<Ayah> _buildAyah(Map<String, dynamic> row) async {
    final surah = row['surah'] as int;
    final ayahNum = row['ayah'] as int;
    final key = '$surah:$ayahNum';
    final cached = _ayahCache[key];
    if (cached != null) return cached;

    final tajweedRaw = await _ds.getTajweedAnnotationsRaw(surah, ayahNum);
    var annotations = const <TajweedAnnotation>[];
    if (tajweedRaw != null && tajweedRaw.isNotEmpty) {
      final list = jsonDecode(tajweedRaw) as List<dynamic>;
      annotations = list.map((e) => TajweedAnnotation.fromMap(e as Map<String, dynamic>)).toList();
    }

    final ayah = Ayah(surah: surah, ayah: ayahNum, text: row['text'] as String, tajweed: annotations);
    _ayahCache[key] = ayah;
    return ayah;
  }

  @override
  Future<List<Ayah>> searchInQuran(String query) async {
    if (query.trim().isEmpty) return const [];

    _allAyahRowsCache ??= await _ds.getAllAyahRows();
    final normalizedQuery = _normalizeArabic(query);
    final results = <Ayah>[];

    for (final row in _allAyahRowsCache!) {
      final normalizedText = _normalizeArabic(row['text'] as String);
      if (normalizedText.contains(normalizedQuery)) {
        results.add(await _buildAyah(row));
      }
    }

    results.sort((a, b) {
      if (a.surah != b.surah) return a.surah.compareTo(b.surah);
      return a.ayah.compareTo(b.ayah);
    });

    return results;
  }

  /// تطبيع النص العربي للبحث (إزالة التشكيل وتوحيد الألف والهمزات)
  String _normalizeArabic(String input) {
    var text = input;
    text = text.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');
    text = text.replaceAll(RegExp(r'[إأآاٱ]'), 'ا');
    text = text.replaceAll('ة', 'ه');
    text = text.replaceAll('ى', 'ي');
    return text.trim();
  }

  @override
  Future<Tafsir?> getTafsir({
    required int surah,
    required int ayah,
    required TafsirType type,
  }) async {
    final row = await _ds.getTafsirRow(surah, ayah, type.dbKey);
    if (row == null) return null;
    return Tafsir(surah: surah, ayah: ayah, type: type, text: row['text'] as String);
  }

  @override
  Future<List<WordMeaning>> getWordMeanings({required int surah, required int ayah}) async {
    final rows = await _ds.getWordMeaningRows(surah, ayah);
    return rows
        .map((r) => WordMeaning(
              surah: r['surah'] as int,
              ayah: r['ayah'] as int,
              word: r['word'] as String,
              meaning: r['meaning'] as String,
            ))
        .toList();
  }

  @override
  Future<bool> hasWordMeanings(int surah, int ayah) async {
    final list = await getWordMeanings(surah: surah, ayah: ayah);
    return list.isNotEmpty;
  }

  @override
  Future<List<TajweedAnnotation>> getTajweedAnnotations(int surah, int ayah) async {
    final ayahObj = await getAyah(surah, ayah);
    return ayahObj?.tajweed ?? const [];
  }

  @override
  Future<AsbabNuzul?> getAsbabNuzul(int surah, int ayah) async {
    var row = await _ds.getAsbabNuzulRow(surah, ayah);

    if (row == null) {
      // قد تشمل رواية واحدة عدة آيات: حقل covers_ayahs يحمل أرقام الآيات
      // العامة (1..6236) وليس رقمها داخل السورة، فنحوّل رقم الآية لرقم عام
      final surahs = await getSurahList();
      var globalId = ayah;
      for (final s in surahs) {
        if (s.number >= surah) break;
        globalId += s.ayahCount;
      }
      final rows = await _ds.getAsbabNuzulRowsForSurah(surah);
      for (final r in rows) {
        final covers = ((r['covers_ayahs'] as String?) ?? '')
            .split(',')
            .map((e) => int.tryParse(e.trim()))
            .whereType<int>();
        if (covers.contains(globalId)) {
          row = r;
          break;
        }
      }
    }

    if (row == null) return null;
    return AsbabNuzul(
      surah: surah,
      ayah: ayah,
      text: row['text'] as String,
    );
  }

  @override
  Future<List<Ayah>> getAyahsStartingOnPage(int pageNumber) async {
    final content = await getMushafPage(pageNumber);
    final minWordPos = <String, int>{};
    final order = <String>[];
    for (final line in content.lines) {
      for (final w in line.words) {
        final key = '${w.surah}:${w.ayah}';
        if (!minWordPos.containsKey(key)) {
          order.add(key);
          minWordPos[key] = w.wordPosition;
        } else if (w.wordPosition < minWordPos[key]!) {
          minWordPos[key] = w.wordPosition;
        }
      }
    }

    final result = <Ayah>[];
    for (final key in order) {
      if (minWordPos[key] != 1) continue; // لا تبدأ هنا فعليًا، امتداد من صفحة سابقة
      final parts = key.split(':');
      final ayah = await getAyah(int.parse(parts[0]), int.parse(parts[1]));
      if (ayah != null) result.add(ayah);
    }
    return result;
  }

  // بدايات الأجزاء (سورة، آية) — معيارية ثابتة، تُحوَّل لأرقام صفحات عند الطلب
  static const List<(int, int)> _juzStarts = [
    (1, 1), (2, 142), (2, 253), (3, 92), (4, 24), (4, 148), (5, 82), (6, 111),
    (7, 88), (8, 41), (9, 93), (11, 6), (12, 53), (15, 1), (17, 1), (18, 75),
    (21, 1), (23, 1), (25, 21), (27, 56), (29, 46), (33, 31), (36, 28), (39, 32),
    (41, 47), (46, 1), (51, 31), (58, 1), (67, 1), (78, 1),
  ];
  List<int>? _juzPagesCache;

  @override
  Future<List<int>> getJuzStartPages() async {
    if (_juzPagesCache != null) return _juzPagesCache!;
    final pages = <int>[];
    for (final (s, a) in _juzStarts) {
      pages.add(await getPageNumberForAyah(s, a));
    }
    _juzPagesCache = pages;
    return pages;
  }

  @override
  Future<Map<int, int>> getWordCountsForSurah(int surah) async {
    if (_wordCountCache.containsKey(surah)) return _wordCountCache[surah]!;
    final rows = await _ds.getWordCountRowsForSurah(surah);
    final map = <int, int>{
      for (final r in rows) (r['ayah'] as int): (r['word_count'] as int),
    };
    _wordCountCache[surah] = map;
    return map;
  }

  @override
  Future<int> getPageNumberForAyah(int surah, int ayah) async {
    final wordRow = await _ds.getWordIndexRow(surah, ayah, 1);
    if (wordRow == null) return 1;
    final wordId = wordRow['word_id'] as int;
    final page = await _ds.getPageNumberForWordId(wordId);
    return page ?? 1;
  }

  // خريطة عالمية: word_id -> (surah,ayah,word_position) — تُملأ تدريجيًا
  // حسب الحاجة فقط (لا نحمّل الـ83 ألف كلمة دفعة واحدة)
  final Map<int, MushafWordRef> _wordIdCache = {};

  @override
  Future<MushafPageContent> getMushafPage(int pageNumber) async {
    final layoutRows = await _ds.getMushafLayoutRows(pageNumber);

    final neededIds = <int>{};
    for (final row in layoutRows) {
      if (row['line_type'] == 'ayah') {
        final f = row['first_word_id'] as int?;
        final l = row['last_word_id'] as int?;
        if (f != null && l != null) {
          for (var id = f; id <= l; id++) {
            if (!_wordIdCache.containsKey(id)) neededIds.add(id);
          }
        }
      }
    }

    if (neededIds.isNotEmpty) {
      final minId = neededIds.reduce((a, b) => a < b ? a : b);
      final maxId = neededIds.reduce((a, b) => a > b ? a : b);
      final wordRows = await _ds.getWordIndexRowsInRange(minId, maxId);
      for (final w in wordRows) {
        final id = w['word_id'] as int;
        _wordIdCache[id] = MushafWordRef(
          surah: w['surah'] as int,
          ayah: w['ayah'] as int,
          wordPosition: w['word_position'] as int,
        );
      }
    }

    final lines = <MushafLine>[];
    for (final row in layoutRows) {
      final lineType = row['line_type'] as String;
      final isCentered = (row['is_centered'] as int) == 1;
      final lineNumber = row['line_number'] as int;

      switch (lineType) {
        case 'surah_name':
          lines.add(MushafLine(
            lineNumber: lineNumber,
            type: MushafLineType.surahName,
            isCentered: isCentered,
            surahNumber: row['surah_number'] as int?,
          ));
          break;
        case 'basmallah':
          lines.add(MushafLine(
            lineNumber: lineNumber,
            type: MushafLineType.basmallah,
            isCentered: isCentered,
          ));
          break;
        default:
          final f = row['first_word_id'] as int?;
          final l = row['last_word_id'] as int?;
          final words = <MushafWordRef>[];
          if (f != null && l != null) {
            for (var id = f; id <= l; id++) {
              final ref = _wordIdCache[id];
              if (ref != null) words.add(ref);
            }
          }
          lines.add(MushafLine(
            lineNumber: lineNumber,
            type: MushafLineType.ayah,
            isCentered: isCentered,
            words: words,
          ));
      }
    }

    return MushafPageContent(pageNumber: pageNumber, lines: lines);
  }
}
