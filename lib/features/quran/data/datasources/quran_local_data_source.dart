import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// طبقة الوصول المباشر لقاعدة بيانات القرآن (quran_data.db)
/// مسؤوليتها الوحيدة: فتح القاعدة ونسخها من الأصول عند أول تشغيل، وتنفيذ
/// الاستعلامات الخام، وإرجاع صفوف (Map) كما هي — دون أي منطق عمل. منطق العمل
/// (التطبيع، التخزين المؤقت، بناء الكيانات) من مسؤولية QuranRepositoryImpl.
///
/// ملاحظة: لا حاجة لحزمة path_provider هنا؛ حزمة sqflite توفّر بنفسها
/// getDatabasesPath() وهو ما نستخدمه، فلا تُضاف أي تبعية جديدة للمشروع.
class QuranLocalDataSource {
  QuranLocalDataSource._();
  static final QuranLocalDataSource instance = QuranLocalDataSource._();

  static const String _assetDbPath = 'assets/data/quran/quran_data.db';
  static const String _dbFileName = 'quran_data.db';

  Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    _db = await _openDatabase();
    return _db!;
  }

  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _dbFileName);

    final alreadyExists = await databaseExists(path);
    if (!alreadyExists) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {
        // المجلد موجود مسبقًا غالبًا؛ لا داعي لإيقاف التنفيذ
      }
      final data = await rootBundle.load(_assetDbPath);
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
    }

    return openDatabase(path, readOnly: true);
  }

  // ===== السور =====
  Future<List<Map<String, dynamic>>> getAllSurahRows() async {
    final db = await _database;
    return db.query('surah_info', orderBy: 'number ASC');
  }

  // ===== الآيات =====
  Future<List<Map<String, dynamic>>> getAyahRowsForSurah(int surah) async {
    final db = await _database;
    return db.query('ayat', where: 'surah = ?', whereArgs: [surah], orderBy: 'ayah ASC');
  }

  Future<Map<String, dynamic>?> getAyahRow(int surah, int ayah) async {
    final db = await _database;
    final rows = await db.query(
      'ayat',
      where: 'surah = ? AND ayah = ?',
      whereArgs: [surah, ayah],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  /// يرجع كل آيات القرآن (تُستخدم مرة واحدة عند أول بحث ثم تُخزَّن مؤقتًا
  /// في الذاكرة من طرف Repository، لأن البحث يحتاج تطبيع النص العربي وهو
  /// أمر لا يدعمه SQLite LIKE مباشرة)
  Future<List<Map<String, dynamic>>> getAllAyahRows() async {
    final db = await _database;
    return db.query('ayat');
  }

  // ===== التفسير =====
  Future<Map<String, dynamic>?> getTafsirRow(int surah, int ayah, String typeKey) async {
    final db = await _database;
    final rows = await db.query(
      'tafsir',
      where: 'surah = ? AND ayah = ? AND type = ?',
      whereArgs: [surah, ayah, typeKey],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  // ===== معاني الكلمات =====
  Future<List<Map<String, dynamic>>> getWordMeaningRows(int surah, int ayah) async {
    final db = await _database;
    return db.query(
      'word_meanings',
      where: 'surah = ? AND ayah = ?',
      whereArgs: [surah, ayah],
    );
  }

  // ===== التجويد =====
  Future<String?> getTajweedAnnotationsRaw(int surah, int ayah) async {
    final db = await _database;
    final rows = await db.query(
      'tajweed',
      where: 'surah = ? AND ayah = ?',
      whereArgs: [surah, ayah],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['annotations'] as String?;
  }

  // ===== تخطيط صفحات المصحف =====
  Future<List<Map<String, dynamic>>> getMushafLayoutRows(int pageNumber) async {
    final db = await _database;
    return db.query(
      'mushaf_layout',
      where: 'page_number = ?',
      whereArgs: [pageNumber],
      orderBy: 'line_number ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getWordIndexRowsInRange(int firstWordId, int lastWordId) async {
    final db = await _database;
    return db.query(
      'word_index',
      where: 'word_id BETWEEN ? AND ?',
      whereArgs: [firstWordId, lastWordId],
      orderBy: 'word_id ASC',
    );
  }

  Future<Map<String, dynamic>?> getWordIndexRow(int surah, int ayah, int wordPosition) async {
    final db = await _database;
    final rows = await db.query(
      'word_index',
      where: 'surah = ? AND ayah = ? AND word_position = ?',
      whereArgs: [surah, ayah, wordPosition],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<int?> getPageNumberForWordId(int wordId) async {
    final db = await _database;
    final rows = await db.query(
      'mushaf_layout',
      columns: ['page_number'],
      where: 'line_type = ? AND first_word_id <= ? AND last_word_id >= ?',
      whereArgs: ['ayah', wordId, wordId],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['page_number'] as int;
  }

  Future<List<Map<String, dynamic>>> getWordCountRowsForSurah(int surah) async {
    final db = await _database;
    return db.rawQuery(
      'SELECT ayah, MAX(word_position) as word_count FROM word_index WHERE surah = ? GROUP BY ayah',
      [surah],
    );
  }

  // ===== أسباب النزول =====
  Future<Map<String, dynamic>?> getAsbabNuzulRow(int surah, int ayah) async {
    final db = await _database;
    final rows = await db.query(
      'asbab_al_nuzul',
      where: 'surah = ? AND ayah = ?',
      whereArgs: [surah, ayah],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  /// كل صفوف أسباب النزول لسورة (للبحث عن رواية تشمل آية بدون صف مستقل)
  Future<List<Map<String, dynamic>>> getAsbabNuzulRowsForSurah(int surah) async {
    final db = await _database;
    return db.query('asbab_al_nuzul', where: 'surah = ?', whereArgs: [surah]);
  }
}
