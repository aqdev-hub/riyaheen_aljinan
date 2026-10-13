/// نوع التفسير المتاح للتبديل
enum TafsirType { muyassar, ibnKathir }

extension TafsirTypeExtension on TafsirType {
  String get label {
    switch (this) {
      case TafsirType.muyassar:
        return 'التفسير الميسر';
      case TafsirType.ibnKathir:
        return 'تفسير ابن كثير';
    }
  }

  /// المفتاح المخزَّن في عمود type بجدول tafsir داخل قاعدة البيانات
  String get dbKey {
    switch (this) {
      case TafsirType.muyassar:
        return 'muyassar';
      case TafsirType.ibnKathir:
        return 'ibn_kathir';
    }
  }
}

/// كيان التفسير — نص تفسير آية واحدة حسب نوع مُحدَّد
class Tafsir {
  final int surah;
  final int ayah;
  final TafsirType type;
  final String text;

  const Tafsir({
    required this.surah,
    required this.ayah,
    required this.type,
    required this.text,
  });
}
