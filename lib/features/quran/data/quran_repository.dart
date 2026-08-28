import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/surah_model.dart';
import '../models/ayah_model.dart';

/// مستودع بيانات القرآن الكريم
/// يقوم بتحميل كل ملفات JSON من assets وتخزينها في الذاكرة (Cache)
/// لتفادي إعادة القراءة من القرص في كل مرة
class QuranRepository {
  QuranRepository._();
  static final QuranRepository instance = QuranRepository._();

  // ===== مسارات الملفات =====
  static const String _pathSurahInfo  = 'assets/data/quran/surah_info.json';
  static const String _pathQuranText  = 'assets/data/quran/quran_text.json';
  static const String _pathWordMeanings = 'assets/data/quran/word_meanings.json';

  // ===== الكاش =====
  List<SurahModel>? _surahs;

  /// نص القرآن مُجمَّع: surahNumber -> List<AyahModel> (مرتبة)
  Map<int, List<AyahModel>>? _quranBySurah;

  /// التفاسير المحمّلة: نخزن كل نوع تفسير منفصل عند أول طلب
  final Map<TafsirType, Map<String, TafsirModel>> _tafsirCache = {};

  /// معاني الكلمات: key = "surah:ayah" -> List<WordMeaningModel>
  Map<String, List<WordMeaningModel>>? _wordMeanings;

  // ========================================
  // تحميل قائمة السور (114 سورة)
  // ========================================
  Future<List<SurahModel>> getSurahList() async {
    if (_surahs != null) return _surahs!;

    final raw = await rootBundle.loadString(_pathSurahInfo);
    final List<dynamic> jsonList = jsonDecode(raw) as List<dynamic>;

    _surahs = jsonList
        .map((e) => SurahModel.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.number.compareTo(b.number));

    return _surahs!;
  }

  /// الحصول على سورة واحدة بالرقم
  Future<SurahModel?> getSurahByNumber(int number) async {
    final list = await getSurahList();
    for (final s in list) {
      if (s.number == number) return s;
    }
    return null;
  }

  // ========================================
  // تحميل نص القرآن كامل (مرة واحدة) وتجميعه حسب السورة
  // ========================================
  Future<void> _ensureQuranTextLoaded() async {
    if (_quranBySurah != null) return;

    final raw = await rootBundle.loadString(_pathQuranText);
    final List<dynamic> jsonList = jsonDecode(raw) as List<dynamic>;

    final Map<int, List<AyahModel>> grouped = {};

    for (final item in jsonList) {
      final ayah = AyahModel.fromJson(item as Map<String, dynamic>);
      grouped.putIfAbsent(ayah.surah, () => []).add(ayah);
    }

    // ترتيب الآيات داخل كل سورة حسب رقم الآية
    for (final list in grouped.values) {
      list.sort((a, b) => a.ayah.compareTo(b.ayah));
    }

    _quranBySurah = grouped;
  }

  /// الحصول على آيات سورة معينة
  Future<List<AyahModel>> getAyahsForSurah(int surahNumber) async {
    await _ensureQuranTextLoaded();
    return _quranBySurah?[surahNumber] ?? const [];
  }

  /// الحصول على آية واحدة محددة
  Future<AyahModel?> getAyah(int surahNumber, int ayahNumber) async {
    final ayahs = await getAyahsForSurah(surahNumber);
    for (final a in ayahs) {
      if (a.ayah == ayahNumber) return a;
    }
    return null;
  }

  // ========================================
  // البحث في نص القرآن
  // ========================================
  Future<List<AyahModel>> searchInQuran(String query) async {
    await _ensureQuranTextLoaded();
    if (query.trim().isEmpty) return const [];

    final normalizedQuery = _normalizeArabic(query);
    final results = <AyahModel>[];

    for (final ayahs in _quranBySurah!.values) {
      for (final ayah in ayahs) {
        final normalizedText = _normalizeArabic(ayah.text);
        if (normalizedText.contains(normalizedQuery)) {
          results.add(ayah);
        }
      }
    }

    // ترتيب النتائج حسب رقم السورة ثم الآية
    results.sort((a, b) {
      if (a.surah != b.surah) return a.surah.compareTo(b.surah);
      return a.ayah.compareTo(b.ayah);
    });

    return results;
  }

  /// تطبيع النص العربي للبحث (إزالة التشكيل وتوحيد الألف والهمزات)
  String _normalizeArabic(String input) {
    var text = input;

    // إزالة التشكيل (الحركات)
    text = text.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');

    // توحيد أشكال الألف
    text = text.replaceAll(RegExp(r'[إأآا]'), 'ا');

    // توحيد التاء المربوطة والهاء
    text = text.replaceAll('ة', 'ه');

    // توحيد الياء والألف المقصورة
    text = text.replaceAll('ى', 'ي');

    return text.trim();
  }

  // ========================================
  // تحميل التفسير (مع كاش لكل نوع)
  // ========================================
  Future<TafsirModel?> getTafsir({
    required int surah,
    required int ayah,
    required TafsirType type,
  }) async {
    final map = await _ensureTafsirLoaded(type);
    return map['$surah:$ayah'];
  }

  Future<Map<String, TafsirModel>> _ensureTafsirLoaded(TafsirType type) async {
    if (_tafsirCache.containsKey(type)) {
      return _tafsirCache[type]!;
    }

    final raw = await rootBundle.loadString(type.assetFileName);
    final List<dynamic> jsonList = jsonDecode(raw) as List<dynamic>;

    final Map<String, TafsirModel> map = {};
    for (final item in jsonList) {
      final t = TafsirModel.fromJson(item as Map<String, dynamic>);
      map[t.key] = t;
    }

    _tafsirCache[type] = map;
    return map;
  }

  // ========================================
  // تحميل معاني الكلمات
  // ========================================
  Future<List<WordMeaningModel>> getWordMeanings({
    required int surah,
    required int ayah,
  }) async {
    await _ensureWordMeaningsLoaded();
    return _wordMeanings?['$surah:$ayah'] ?? const [];
  }

  Future<void> _ensureWordMeaningsLoaded() async {
    if (_wordMeanings != null) return;

    try {
      final raw = await rootBundle.loadString(_pathWordMeanings);
      final List<dynamic> jsonList = jsonDecode(raw) as List<dynamic>;

      final Map<String, List<WordMeaningModel>> grouped = {};
      for (final item in jsonList) {
        final w = WordMeaningModel.fromJson(item as Map<String, dynamic>);
        grouped.putIfAbsent(w.key, () => []).add(w);
      }

      _wordMeanings = grouped;
    } catch (_) {
      // إذا لم يكن الملف موجوداً بعد، نتعامل بهدوء
      _wordMeanings = {};
    }
  }

  /// هل توجد معاني كلمات لهذه الآية؟
  Future<bool> hasWordMeanings(int surah, int ayah) async {
    await _ensureWordMeaningsLoaded();
    final list = _wordMeanings?['$surah:$ayah'];
    return list != null && list.isNotEmpty;
  }
}
