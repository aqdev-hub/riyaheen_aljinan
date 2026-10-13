import 'tajweed_annotation.dart';

/// كيان الآية — النص + قائمة أحكام التجويد المرتبطة به
class Ayah {
  final int surah;
  final int ayah;
  final String text;
  final List<TajweedAnnotation> tajweed;

  const Ayah({
    required this.surah,
    required this.ayah,
    required this.text,
    this.tajweed = const [],
  });

  /// مفتاح فريد للآية (مفيد لـ Map / Bookmarks)
  String get key => '$surah:$ayah';
}
