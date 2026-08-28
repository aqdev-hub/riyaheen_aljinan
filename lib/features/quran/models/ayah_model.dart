/// نموذج بيانات الآية
class AyahModel {
  final int surah;
  final int ayah;
  final String text;

  const AyahModel({
    required this.surah,
    required this.ayah,
    required this.text,
  });

  factory AyahModel.fromJson(Map<String, dynamic> json) {
    return AyahModel(
      surah: json['surah'] as int,
      ayah:  json['ayah'] as int,
      text:  json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'surah': surah,
    'ayah':  ayah,
    'text':  text,
  };

  /// مفتاح فريد للآية (مفيد لـ Map / Bookmarks)
  String get key => '$surah:$ayah';
}

/// نموذج التفسير (يصلح للميسر وابن كثير بنفس البنية)
class TafsirModel {
  final int surah;
  final int ayah;
  final String text;

  const TafsirModel({
    required this.surah,
    required this.ayah,
    required this.text,
  });

  factory TafsirModel.fromJson(Map<String, dynamic> json) {
    return TafsirModel(
      surah: json['surah'] as int,
      ayah:  json['ayah'] as int,
      text:  json['text'] as String,
    );
  }

  String get key => '$surah:$ayah';
}

/// نموذج معاني الكلمات الغريبة
class WordMeaningModel {
  final int surah;
  final int ayah;
  final String word;
  final String meaning;

  const WordMeaningModel({
    required this.surah,
    required this.ayah,
    required this.word,
    required this.meaning,
  });

  factory WordMeaningModel.fromJson(Map<String, dynamic> json) {
    return WordMeaningModel(
      surah:   json['surah'] as int,
      ayah:    json['ayah'] as int,
      word:    json['word'] as String,
      meaning: json['meaning'] as String,
    );
  }

  String get key => '$surah:$ayah';
}

/// نوع التفسير المتاح للتبديل
enum TafsirType {
  muyassar,
  ibnKathir,
}

extension TafsirTypeExtension on TafsirType {
  String get label {
    switch (this) {
      case TafsirType.muyassar:
        return 'التفسير الميسر';
      case TafsirType.ibnKathir:
        return 'تفسير ابن كثير';
    }
  }

  String get assetFileName {
    switch (this) {
      case TafsirType.muyassar:
        return 'assets/data/quran/tafsir_muyassar.json';
      case TafsirType.ibnKathir:
        return 'assets/data/quran/tafsir_ibn_kathir.json';
    }
  }
}
