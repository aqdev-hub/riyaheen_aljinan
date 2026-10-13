import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/quran_local_data_source.dart';
import '../../data/repositories/quran_repository_impl.dart';
import '../../domain/entities/mushaf_line.dart';
import '../../domain/entities/surah.dart';
import '../../domain/entities/tafsir.dart';
import '../../domain/repositories/quran_repository.dart';

// ============================================================
// المستودع (الحقن الوحيد للاعتمادية — لا Singleton ساكن)
// ============================================================
final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  return QuranRepositoryImpl(QuranLocalDataSource.instance);
});

// ============================================================
// بيانات القراءة فقط (تُخزَّن مؤقتًا تلقائيًا بواسطة Riverpod)
// ============================================================
final surahListProvider = FutureProvider<List<Surah>>((ref) {
  return ref.watch(quranRepositoryProvider).getSurahList();
});

final surahByNumberProvider = FutureProvider.family<Surah?, int>((ref, number) {
  return ref.watch(quranRepositoryProvider).getSurahByNumber(number);
});

final mushafPageProvider = FutureProvider.family<MushafPageContent, int>((ref, page) {
  return ref.watch(quranRepositoryProvider).getMushafPage(page);
});

final juzStartPagesProvider = FutureProvider<List<int>>((ref) {
  return ref.watch(quranRepositoryProvider).getJuzStartPages();
});

// ============================================================
// إعدادات القرآن (محفوظة في SharedPreferences)
// ============================================================
class QuranSettingsState {
  final int lastSurah;
  final int lastAyah;
  final double fontSize;
  final TafsirType tafsirType;
  final Set<String> bookmarks;
  final bool tajweedEnabled;
  final int pageBackgroundIndex;
  final int verseColorValue;
  final int textColorValue;
  final String studyFontFamily;
  final bool showSilentMark;
  final bool isLoaded;

  const QuranSettingsState({
    this.lastSurah = 1,
    this.lastAyah = 1,
    this.fontSize = 20.0,
    this.tafsirType = TafsirType.muyassar,
    this.bookmarks = const {},
    this.tajweedEnabled = true,
    this.pageBackgroundIndex = 1,
    this.verseColorValue = 0xFF4A3300,
    this.textColorValue = 0xFF3B3B3B,
    this.studyFontFamily = 'Uthmanic',
    this.showSilentMark = false,
    this.isLoaded = false,
  });

  QuranSettingsState copyWith({
    int? lastSurah,
    int? lastAyah,
    double? fontSize,
    TafsirType? tafsirType,
    Set<String>? bookmarks,
    bool? tajweedEnabled,
    int? pageBackgroundIndex,
    int? verseColorValue,
    int? textColorValue,
    String? studyFontFamily,
    bool? showSilentMark,
    bool? isLoaded,
  }) {
    return QuranSettingsState(
      lastSurah: lastSurah ?? this.lastSurah,
      lastAyah: lastAyah ?? this.lastAyah,
      fontSize: fontSize ?? this.fontSize,
      tafsirType: tafsirType ?? this.tafsirType,
      bookmarks: bookmarks ?? this.bookmarks,
      tajweedEnabled: tajweedEnabled ?? this.tajweedEnabled,
      pageBackgroundIndex: pageBackgroundIndex ?? this.pageBackgroundIndex,
      verseColorValue: verseColorValue ?? this.verseColorValue,
      textColorValue: textColorValue ?? this.textColorValue,
      studyFontFamily: studyFontFamily ?? this.studyFontFamily,
      showSilentMark: showSilentMark ?? this.showSilentMark,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  bool isBookmarked(int surah, int ayah) => bookmarks.contains('$surah:$ayah');

  /// قائمة الإشارات المرجعية كـ (surah, ayah) مرتبة
  List<(int, int)> get bookmarksList {
    return bookmarks.map((key) {
      final parts = key.split(':');
      return (int.parse(parts[0]), int.parse(parts[1]));
    }).toList()
      ..sort((a, b) => a.$1 != b.$1 ? a.$1.compareTo(b.$1) : a.$2.compareTo(b.$2));
  }
}

class QuranSettingsNotifier extends Notifier<QuranSettingsState> {
  static const _keyLastSurah = 'quran_last_surah';
  static const _keyLastAyah = 'quran_last_ayah';
  static const _keyFontSize = 'quran_font_size';
  static const _keyTafsirType = 'quran_tafsir_type';
  static const _keyBookmarks = 'quran_bookmarks';
  static const _keyTajweed = 'quran_tajweed_enabled';
  static const _keyBackground = 'quran_page_background';
  static const _keyVerseColor = 'quran_verse_color';
  static const _keyTextColor = 'quran_text_color';
  static const _keyStudyFont = 'quran_study_font';
  static const _keySilentMark = 'quran_show_silent_mark';

  static const double minFontSize = 14.0;
  static const double maxFontSize = 40.0;

  @override
  QuranSettingsState build() {
    Future.microtask(_load);
    return const QuranSettingsState();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final tafsirIndex = prefs.getInt(_keyTafsirType) ?? 0;
    final bookmarksJson = prefs.getString(_keyBookmarks);
    final bookmarks = <String>{};
    if (bookmarksJson != null) {
      final list = jsonDecode(bookmarksJson) as List<dynamic>;
      bookmarks.addAll(list.map((e) => e.toString()));
    }

    state = QuranSettingsState(
      lastSurah: prefs.getInt(_keyLastSurah) ?? 1,
      lastAyah: prefs.getInt(_keyLastAyah) ?? 1,
      fontSize: prefs.getDouble(_keyFontSize) ?? 20.0,
      tafsirType: TafsirType.values[tafsirIndex.clamp(0, TafsirType.values.length - 1)],
      bookmarks: bookmarks,
      tajweedEnabled: prefs.getBool(_keyTajweed) ?? true,
      pageBackgroundIndex: prefs.getInt(_keyBackground) ?? 1,
      verseColorValue: prefs.getInt(_keyVerseColor) ?? 0xFF4A3300,
      textColorValue: prefs.getInt(_keyTextColor) ?? 0xFF3B3B3B,
      studyFontFamily: prefs.getString(_keyStudyFont) ?? 'Uthmanic',
      showSilentMark: prefs.getBool(_keySilentMark) ?? false,
      isLoaded: true,
    );
  }

  Future<void> setLastRead(int surah, int ayah) async {
    state = state.copyWith(lastSurah: surah, lastAyah: ayah);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastSurah, surah);
    await prefs.setInt(_keyLastAyah, ayah);
  }

  Future<void> setFontSize(double size) async {
    final clamped = size.clamp(minFontSize, maxFontSize);
    state = state.copyWith(fontSize: clamped);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyFontSize, clamped);
  }

  Future<void> setTafsirType(TafsirType type) async {
    state = state.copyWith(tafsirType: type);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTafsirType, type.index);
  }

  Future<void> setTajweedEnabled(bool enabled) async {
    state = state.copyWith(tajweedEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTajweed, enabled);
  }

  Future<void> setPageBackground(int index) async {
    state = state.copyWith(pageBackgroundIndex: index);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyBackground, index);
  }

  /// حفظ دفعة واحدة لإعدادات نافذة "ضبط" (خط، ألوان، تجويد)
  Future<void> saveStudyAppearance({
    required double fontSize,
    required int verseColorValue,
    required int textColorValue,
    required String fontFamily,
    required bool tajweedEnabled,
    required bool showSilentMark,
  }) async {
    final clamped = fontSize.clamp(minFontSize, maxFontSize);
    state = state.copyWith(
      fontSize: clamped,
      verseColorValue: verseColorValue,
      textColorValue: textColorValue,
      studyFontFamily: fontFamily,
      tajweedEnabled: tajweedEnabled,
      showSilentMark: showSilentMark,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyFontSize, clamped);
    await prefs.setInt(_keyVerseColor, verseColorValue);
    await prefs.setInt(_keyTextColor, textColorValue);
    await prefs.setString(_keyStudyFont, fontFamily);
    await prefs.setBool(_keyTajweed, tajweedEnabled);
    await prefs.setBool(_keySilentMark, showSilentMark);
  }

  Future<void> toggleBookmark(int surah, int ayah) async {
    final key = '$surah:$ayah';
    final updated = {...state.bookmarks};
    if (!updated.remove(key)) updated.add(key);
    state = state.copyWith(bookmarks: updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBookmarks, jsonEncode(updated.toList()));
  }
}

final quranSettingsProvider =
    NotifierProvider<QuranSettingsNotifier, QuranSettingsState>(QuranSettingsNotifier.new);

// ============================================================
// حالة القارئ المصحفي: الصفحة الحالية والآية المحددة
// ============================================================
class MushafReaderState {
  final int currentPage;
  final int? selectedSurah;
  final int? selectedAyah;
  final bool toolbarVisible;

  const MushafReaderState({
    this.currentPage = 1,
    this.selectedSurah,
    this.selectedAyah,
    this.toolbarVisible = false,
  });

  bool get hasSelection => selectedSurah != null && selectedAyah != null;

  MushafReaderState copyWith({
    int? currentPage,
    int? selectedSurah,
    int? selectedAyah,
    bool? toolbarVisible,
    bool clearSelection = false,
  }) {
    return MushafReaderState(
      currentPage: currentPage ?? this.currentPage,
      selectedSurah: clearSelection ? null : (selectedSurah ?? this.selectedSurah),
      selectedAyah: clearSelection ? null : (selectedAyah ?? this.selectedAyah),
      toolbarVisible: toolbarVisible ?? this.toolbarVisible,
    );
  }
}

class MushafReaderNotifier extends Notifier<MushafReaderState> {
  @override
  MushafReaderState build() => const MushafReaderState();

  void setPage(int page) => state = state.copyWith(currentPage: page);

  /// يحدد آية؛ [showToolbar] = false لتحديدها (تظليلها) دون إظهار الشريط السفلي
  void selectAyah(int surah, int ayah, {bool showToolbar = true}) {
    state = state.copyWith(
      selectedSurah: surah,
      selectedAyah: ayah,
      toolbarVisible: showToolbar ? true : state.toolbarVisible,
    );
  }

  /// يغلق الشريط السفلي ويزيل تظليل الآية المحددة (لأي ضغطة خارج الشريط)
  void dismissToolbar() => state = state.copyWith(toolbarVisible: false, clearSelection: true);

  void clearSelection() => state = state.copyWith(clearSelection: true);

  void toggleToolbar() => state = state.copyWith(toolbarVisible: !state.toolbarVisible);

  void hideToolbar() => state = state.copyWith(toolbarVisible: false);
}

final mushafReaderProvider =
    NotifierProvider<MushafReaderNotifier, MushafReaderState>(MushafReaderNotifier.new);
