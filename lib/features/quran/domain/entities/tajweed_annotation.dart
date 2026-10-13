/// تعليق تجويدي واحد: يمثّل حكمًا تجويديًا على مدى معيّن من أحرف نص الآية
/// [start] و[end] هما إزاحتا بداية/نهاية المدى (end غير شامل) بوحدة "نقطة الكود"
/// (code point) داخل نص الآية كما هو مخزَّن في جدول ayat — وهو نفس نظام العدّ
/// الذي تستخدمه سلاسل Dart لهذا النطاق من الأحرف العربية (لا يوجد اختلاف عملي
/// لأن كل رموز القرآن هنا تقع ضمن المستوى الأساسي متعدد اللغات BMP).
class TajweedAnnotation {
  final int start;
  final int end;
  final String rule;

  const TajweedAnnotation({
    required this.start,
    required this.end,
    required this.rule,
  });

  factory TajweedAnnotation.fromMap(Map<String, dynamic> map) {
    return TajweedAnnotation(
      start: map['start'] as int,
      end: map['end'] as int,
      rule: map['rule'] as String,
    );
  }
}
