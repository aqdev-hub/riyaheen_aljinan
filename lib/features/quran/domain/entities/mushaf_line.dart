/// نوع السطر داخل صفحة المصحف
enum MushafLineType {
  surahName, // سطر عنوان سورة زخرفي
  basmallah, // سطر البسملة المستقل (لا يتبع أي آية بعينها)
  ayah, // سطر يحتوي كلمات من آية أو أكثر
}

/// إشارة إلى كلمة واحدة ضمن آية معيّنة، تُستخدم لمعرفة أي أجزاء الآيات
/// تقع في أي سطر من أسطر صفحة المصحف (بيانات وصفية فقط، لا نص فيها)
class MushafWordRef {
  final int surah;
  final int ayah;
  final int wordPosition; // ترقيم الكلمة داخل الآية بدءًا من 1

  const MushafWordRef({
    required this.surah,
    required this.ayah,
    required this.wordPosition,
  });
}

/// سطر واحد من أسطر صفحة المصحف الخمسة عشر
class MushafLine {
  final int lineNumber;
  final MushafLineType type;
  final bool isCentered;
  final int? surahNumber; // للسطور من نوع surahName فقط
  final List<MushafWordRef> words; // للسطور من نوع ayah فقط

  const MushafLine({
    required this.lineNumber,
    required this.type,
    required this.isCentered,
    this.surahNumber,
    this.words = const [],
  });
}

/// محتوى صفحة كاملة من صفحات المصحف الـ604
class MushafPageContent {
  final int pageNumber;
  final List<MushafLine> lines;

  const MushafPageContent({
    required this.pageNumber,
    required this.lines,
  });
}
