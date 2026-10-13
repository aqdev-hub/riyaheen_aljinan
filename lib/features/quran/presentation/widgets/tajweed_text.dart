import 'package:flutter/material.dart';
import '../../core/tajweed_colors.dart';
import '../../domain/entities/tajweed_annotation.dart';

/// يعرض نص آية (أو جزءًا منها) ملوّنًا حسب أحكام التجويد المرفقة معها.
/// عند تداخل حكمين على نفس الحرف يفوز آخر حكم يرد في القائمة (نادر الحدوث).
/// عند [enabled] = false يُعرض النص عاديًا بلا أي تلوين (لمن يفضّل ذلك).
class TajweedText extends StatelessWidget {
  final String text;
  final List<TajweedAnnotation> annotations;
  final TextStyle baseStyle;
  final TextAlign textAlign;
  final bool enabled;

  const TajweedText({
    super.key,
    required this.text,
    required this.annotations,
    required this.baseStyle,
    this.textAlign = TextAlign.justify,
    this.enabled = true,
  });

  /// يبني قائمة TextSpan ملوّنة، قابلة لإعادة الاستخدام من عناصر أخرى
  /// تحتاج دمج عدة أجزاء ملوّنة داخل RichText واحد (مثل صفحة المصحف)
  static List<TextSpan> buildSpans({
    required String text,
    required List<TajweedAnnotation> annotations,
    TextStyle? style,
    bool enabled = true,
  }) {
    if (!enabled || annotations.isEmpty || text.isEmpty) {
      return [TextSpan(text: text, style: style)];
    }

    final colorPerChar = List<Color?>.filled(text.length, null);
    for (final ann in annotations) {
      final start = ann.start.clamp(0, text.length);
      final end = ann.end.clamp(0, text.length);
      final color = TajweedColors.colorFor(ann.rule);
      for (var i = start; i < end; i++) {
        colorPerChar[i] = color;
      }
    }

    final spans = <TextSpan>[];
    var i = 0;
    while (i < text.length) {
      final color = colorPerChar[i];
      var j = i + 1;
      while (j < text.length && colorPerChar[j] == color) {
        j++;
      }
      spans.add(TextSpan(
        text: text.substring(i, j),
        style: color != null ? (style ?? const TextStyle()).copyWith(color: color) : style,
      ));
      i = j;
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: textAlign,
      textDirection: TextDirection.rtl,
      text: TextSpan(
        style: baseStyle,
        children: buildSpans(text: text, annotations: annotations, style: baseStyle, enabled: enabled),
      ),
    );
  }
}
