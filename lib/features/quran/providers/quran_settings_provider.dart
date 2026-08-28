import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ayah_model.dart';

/// مزود إعدادات وحالة قسم القرآن
/// يدير: آخر موضع قراءة، الإشارات المرجعية، حجم الخط، نوع التفسير
class QuranSettingsProvider extends ChangeNotifier {
  // ===== مفاتيح التخزين =====
  static const _keyLastSurah   = 'quran_last_surah';
  static const _keyLastAyah    = 'quran_last_ayah';
  static const _keyFontSize    = 'quran_font_size';
  static const _keyTafsirType  = 'quran_tafsir_type';
  static const _keyBookmarks   = 'quran_bookmarks';

  // ===== القيم الافتراضية =====
  int _lastSurah = 1;
  int _lastAyah  = 1;
  double _fontSize = 24.0;
  TafsirType _tafsirType = TafsirType.muyassar;
  final Set<String> _bookmarks = {};

  bool _isLoaded = false;

  // ===== Getters =====
  int get lastSurah => _lastSurah;
  int get lastAyah  => _lastAyah;
  double get fontSize => _fontSize;
  TafsirType get tafsirType => _tafsirType;
  Set<String> get bookmarks => _bookmarks;
  bool get isLoaded => _isLoaded;

  /// حدود حجم الخط
  static const double minFontSize = 18.0;
  static const double maxFontSize = 40.0;

  // ========================================
  // تحميل الإعدادات المحفوظة
  // ========================================
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    _lastSurah = prefs.getInt(_keyLastSurah) ?? 1;
    _lastAyah  = prefs.getInt(_keyLastAyah) ?? 1;
    _fontSize  = prefs.getDouble(_keyFontSize) ?? 24.0;

    final tafsirIndex = prefs.getInt(_keyTafsirType) ?? 0;
    _tafsirType = TafsirType.values[tafsirIndex.clamp(0, TafsirType.values.length - 1)];

    final bookmarksJson = prefs.getString(_keyBookmarks);
    if (bookmarksJson != null) {
      final List<dynamic> list = jsonDecode(bookmarksJson) as List<dynamic>;
      _bookmarks.clear();
      _bookmarks.addAll(list.map((e) => e.toString()));
    }

    _isLoaded = true;
    notifyListeners();
  }

  // ========================================
  // آخر موضع قراءة
  // ========================================
  Future<void> setLastRead(int surah, int ayah) async {
    _lastSurah = surah;
    _lastAyah  = ayah;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastSurah, surah);
    await prefs.setInt(_keyLastAyah, ayah);
  }

  // ========================================
  // حجم الخط
  // ========================================
  Future<void> setFontSize(double size) async {
    _fontSize = size.clamp(minFontSize, maxFontSize);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyFontSize, _fontSize);
  }

  Future<void> increaseFontSize() async {
    await setFontSize(_fontSize + 2);
  }

  Future<void> decreaseFontSize() async {
    await setFontSize(_fontSize - 2);
  }

  // ========================================
  // نوع التفسير
  // ========================================
  Future<void> setTafsirType(TafsirType type) async {
    _tafsirType = type;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTafsirType, type.index);
  }

  // ========================================
  // الإشارات المرجعية (Bookmarks)
  // ========================================
  bool isBookmarked(int surah, int ayah) {
    return _bookmarks.contains('$surah:$ayah');
  }

  Future<void> toggleBookmark(int surah, int ayah) async {
    final key = '$surah:$ayah';
    if (_bookmarks.contains(key)) {
      _bookmarks.remove(key);
    } else {
      _bookmarks.add(key);
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBookmarks, jsonEncode(_bookmarks.toList()));
  }

  /// قائمة الإشارات المرجعية كـ (surah, ayah)
  List<(int, int)> get bookmarksList {
    return _bookmarks.map((key) {
      final parts = key.split(':');
      return (int.parse(parts[0]), int.parse(parts[1]));
    }).toList()
      ..sort((a, b) {
        if (a.$1 != b.$1) return a.$1.compareTo(b.$1);
        return a.$2.compareTo(b.$2);
      });
  }
}
