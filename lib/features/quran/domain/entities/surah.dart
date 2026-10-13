/// كيان السورة (Domain Entity) — بيانات نقية بلا أي منطق تحميل أو تخزين
class Surah {
  final int number;
  final String name;
  final String englishName;
  final int ayahCount;
  final String revelationType; // Meccan / Medinan

  const Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.ayahCount,
    required this.revelationType,
  });

  /// هل السورة مكية؟
  bool get isMeccan => revelationType == 'Meccan';

  /// النص المعروض (مكية / مدنية)
  String get revelationLabel => isMeccan ? 'مكية' : 'مدنية';

  factory Surah.fromMap(Map<String, dynamic> map) {
    return Surah(
      number: map['number'] as int,
      name: map['name'] as String,
      englishName: map['english_name'] as String,
      ayahCount: map['ayah_count'] as int,
      revelationType: map['revelation_type'] as String,
    );
  }
}
