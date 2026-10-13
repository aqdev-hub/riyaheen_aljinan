/// كيان معنى كلمة غريبة داخل آية معيّنة
class WordMeaning {
  final int surah;
  final int ayah;
  final String word;
  final String meaning;

  const WordMeaning({
    required this.surah,
    required this.ayah,
    required this.word,
    required this.meaning,
  });

  String get key => '$surah:$ayah';
}
