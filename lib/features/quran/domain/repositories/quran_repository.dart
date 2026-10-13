import '../entities/asbab_nuzul.dart';
import '../entities/ayah.dart';
import '../entities/mushaf_line.dart';
import '../entities/surah.dart';
import '../entities/tafsir.dart';
import '../entities/tajweed_annotation.dart';
import '../entities/word_meaning.dart';

/// العقد المجرّد لمستودع بيانات القرآن — لا يعرف كيف تُخزَّن البيانات فعليًا
/// (SQLite حاليًا)، فقط "ما الذي يمكن طلبه" من طبقة العرض. يُحقن عبر
/// Riverpod (quranRepositoryProvider) بدل أي Singleton ساكن.
abstract class QuranRepository {
  /// إجمالي عدد صفحات المصحف المطبوع (604 صفحة، تخطيط مصحف المدينة)
  int get totalPages;

  Future<List<Surah>> getSurahList();
  Future<Surah?> getSurahByNumber(int number);

  Future<List<Ayah>> getAyahsForSurah(int surahNumber);
  Future<Ayah?> getAyah(int surahNumber, int ayahNumber);
  Future<List<Ayah>> searchInQuran(String query);

  Future<Tafsir?> getTafsir({
    required int surah,
    required int ayah,
    required TafsirType type,
  });

  Future<List<WordMeaning>> getWordMeanings({required int surah, required int ayah});
  Future<bool> hasWordMeanings(int surah, int ayah);

  Future<List<TajweedAnnotation>> getTajweedAnnotations(int surah, int ayah);

  /// سبب نزول آية معيّنة (أو null إن لم يُذكر لها سبب في المصدر)
  Future<AsbabNuzul?> getAsbabNuzul(int surah, int ayah);

  /// أرقام صفحات بداية كل جزء (30 عنصرًا) لفهرس الأجزاء
  Future<List<int>> getJuzStartPages();

  /// عدد كلمات كل آية في سورة معيّنة (مطلوب لمعرفة هل نطاق كلمات على سطر
  /// معيّن يغطي الآية كاملة أم جزءًا منها فقط عند حدود الصفحة)
  Future<Map<int, int>> getWordCountsForSurah(int surah);

  /// محتوى صفحة مصحفية كاملة برقمها (1 إلى 604)
  Future<MushafPageContent> getMushafPage(int pageNumber);

  /// كل الآيات التي *تبدأ* فعليًا في هذه الصفحة (لا التي تمتد إليها من
  /// صفحة سابقة) — لعرض قراءة متصلة (تفسير/معاني/سبب نزول) صفحة بصفحة
  /// بنفس ترقيم صفحات المصحف الـ604 دون تكرار أي آية في صفحتين
  Future<List<Ayah>> getAyahsStartingOnPage(int pageNumber);

  /// رقم الصفحة المصحفية التي تبدأ فيها آية معيّنة
  Future<int> getPageNumberForAyah(int surah, int ayah);
}
