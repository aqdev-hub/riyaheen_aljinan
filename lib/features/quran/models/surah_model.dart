/// نموذج بيانات السورة
class SurahModel {
  final int number;
  final String name;
  final String englishName;
  final int ayahCount;
  final String revelationType; // Meccan / Medinan

  const SurahModel({
    required this.number,
    required this.name,
    required this.englishName,
    required this.ayahCount,
    required this.revelationType,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      number:         json['number'] as int,
      name:           json['name'] as String,
      englishName:    json['englishName'] as String,
      ayahCount:      json['ayahCount'] as int,
      revelationType: json['revelationType'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'number':         number,
    'name':           name,
    'englishName':    englishName,
    'ayahCount':      ayahCount,
    'revelationType': revelationType,
  };

  /// هل السورة مكية؟
  bool get isMeccan => revelationType == 'Meccan';

  /// النص المعروض (مكية / مدنية)
  String get revelationLabel => isMeccan ? 'مكية' : 'مدنية';
}
