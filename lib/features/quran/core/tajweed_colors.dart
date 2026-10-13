import 'package:flutter/material.dart';

/// ألوان أحكام التجويد الثمانية عشر التي يغطيها محرك التصنيف
/// (مصدر البيانات: مشروع quran-tajweed مفتوح المصدر CC-BY 4.0،
/// أُعيد توليدها بالكامل لتطابق نص هذا التطبيق حرفيًا — راجع ملاحظات
/// التسليم لتفاصيل عملية إعادة التوليد والتحقق)
class TajweedColors {
  TajweedColors._();

  static const Map<String, Color> ruleColors = {
    'ghunnah': Color(0xFFFF9800), // غنّة
    'idghaam_ghunnah': Color(0xFF8BC34A), // إدغام بغنّة
    'idghaam_no_ghunnah': Color(0xFF2E7D32), // إدغام بلا غنّة
    'idghaam_mutajanisayn': Color(0xFF00897B), // إدغام متجانسين
    'idghaam_mutaqaribayn': Color(0xFF26A69A), // إدغام متقاربين
    'idghaam_shafawi': Color(0xFF689F38), // إدغام شفوي
    'ikhfa': Color(0xFF9C27B0), // إخفاء
    'ikhfa_shafawi': Color(0xFFBA68C8), // إخفاء شفوي
    'iqlab': Color(0xFF1976D2), // إقلاب
    'lam_shamsiyyah': Color(0xFF9E9E9E), // لام شمسية
    'madd_2': Color(0xFFEF5350), // مد حركتين (طبيعي)
    'madd_246': Color(0xFFE53935), // مد جائز (2/4/6 حركات)
    'madd_6': Color(0xFFB71C1C), // مد لازم (6 حركات)
    'madd_munfasil': Color(0xFFFF7043), // مد جائز منفصل
    'madd_muttasil': Color(0xFFD32F2F), // مد واجب متصل
    'qalqalah': Color(0xFFFFB300), // قلقلة
    'hamzat_wasl': Color(0xFF757575), // همزة وصل
    'silent': Color(0xFF795548), // حرف ساكت لا يُلفظ (بنّي واضح؛ كان شبه شفاف)
  };

  static const Map<String, String> ruleLabels = {
    'ghunnah': 'غنّة',
    'idghaam_ghunnah': 'إدغام بغنّة',
    'idghaam_no_ghunnah': 'إدغام بلا غنّة',
    'idghaam_mutajanisayn': 'إدغام متجانسين',
    'idghaam_mutaqaribayn': 'إدغام متقاربين',
    'idghaam_shafawi': 'إدغام شفوي',
    'ikhfa': 'إخفاء',
    'ikhfa_shafawi': 'إخفاء شفوي',
    'iqlab': 'إقلاب',
    'lam_shamsiyyah': 'لام شمسية',
    'madd_2': 'مدّ حركتين',
    'madd_246': 'مدّ جائز',
    'madd_6': 'مدّ لازم',
    'madd_munfasil': 'مدّ منفصل',
    'madd_muttasil': 'مدّ متصل',
    'qalqalah': 'قلقلة',
    'hamzat_wasl': 'همزة وصل',
    'silent': 'حرف ساكت',
  };

  static Color colorFor(String rule) => ruleColors[rule] ?? const Color(0xFF000000);
  static String labelFor(String rule) => ruleLabels[rule] ?? rule;

  /// ترتيب ثابت لعرض قائمة الأحكام في شاشة "دليل الألوان"
  static List<String> get orderedRules => ruleColors.keys.toList();

  /// نص البسملة كما يتكرر أعلى كل صفحة (باستثناء الصفحة الأولى والتاسعة)
  /// مع تعليقات تجويدها المطابقة تمامًا لأول آية في سورة الفاتحة، محفوظة هنا
  /// كقيمة ثابتة بدل استعلام قاعدة البيانات لأجل سطر زخرفي متكرر فقط.
  static const String basmalaText = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';

  static const List<Map<String, Object>> basmalaAnnotationMaps = [
    {'start': 7, 'end': 8, 'rule': 'hamzat_wasl'},
    {'start': 15, 'end': 16, 'rule': 'hamzat_wasl'},
    {'start': 16, 'end': 17, 'rule': 'lam_shamsiyyah'},
    {'start': 24, 'end': 25, 'rule': 'madd_2'},
    {'start': 28, 'end': 29, 'rule': 'hamzat_wasl'},
    {'start': 29, 'end': 30, 'rule': 'lam_shamsiyyah'},
    {'start': 35, 'end': 36, 'rule': 'madd_246'},
  ];
}
