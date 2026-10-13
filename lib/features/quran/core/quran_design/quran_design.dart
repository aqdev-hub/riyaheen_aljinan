import 'dart:math' as math;
import 'package:flutter/material.dart';

/// نظام التصميم المشترك لقسم القرآن — كل العناصر الزخرفية المتكررة عبر
/// الشاشات (اللفافة الورقية، شارة رقم الآية، شريط اسم السورة، أيقونات
/// مكي/مدني) في ملف واحد بدل تكرارها أو تشتيتها، بنفس أسلوب الملفات
/// المشتركة المعتمد في مشروع "ذمّة".
class QuranDesignColors {
  QuranDesignColors._();

  // ===== اللفافة الورقية (Scroll) =====
  static const Color parchmentBg = Color(0xFFE9D8B4);
  static const Color parchmentBgDark = Color(0xFF3A2E1F);
  static const Color woodBorder = Color(0xFF6B3F1D);
  static const Color ribbonTeal = Color(0xFF0E6B6F);

  // ===== القائمة الليلية الافتتاحية (كصورة القائمة الأولى) =====
  static const Color navyMenuBg = Color(0xFF0F2A43);
  static const Color navyMenuBorder = Color(0xFF29ABE2);

  // ===== خلفيات صفحة المصحف القابلة للاختيار =====
  static const List<MapEntry<String, Color>> pageBackgrounds = [
    MapEntry('بيج', Color(0xFFF0EDE5)),
    MapEntry('نعناعي', Color(0xFFD9EDE6)),
    MapEntry('أزرق', Color(0xFFBFE0EE)),
    MapEntry('أبيض', Color(0xFFFFFFFF)),
  ];
}

/// يحوّل رقمًا صحيحًا إلى أرقام هندية (شرقية) كما تُكتب في المصحف
String toEasternArabicDigits(int number) {
  const western = '0123456789';
  const eastern = '٠١٢٣٤٥٦٧٨٩';
  return number.toString().split('').map((ch) {
    final i = western.indexOf(ch);
    return i == -1 ? ch : eastern[i];
  }).join();
}

/// لفافة ورقية زخرفية بحواف خشبية منحوتة وشريط عنوان (راية) — الشكل
/// المستخدم لكل النوافذ المنبثقة من صفحة المصحف (معاني، بحث، فهرس، تفسير،
/// سبب النزول، الإعدادات)
class OrnateScrollSheet extends StatelessWidget {
  final String title;

  /// يبني محتوى اللفافة؛ يجب أن يستخدم [ScrollController] الممرَّر لقائمته
  /// القابلة للتمرير كي يعمل سحب اللفافة وتمرير المحتوى معًا
  final Widget Function(BuildContext context, ScrollController controller) builder;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;

  const OrnateScrollSheet({
    super.key,
    required this.title,
    required this.builder,
    this.initialChildSize = 0.62,
    this.minChildSize = 0.35,
    this.maxChildSize = 0.94,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget Function(BuildContext context, ScrollController controller) builder,
    double initialChildSize = 0.62,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OrnateScrollSheet(
        title: title,
        initialChildSize: initialChildSize,
        builder: builder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? QuranDesignColors.parchmentBgDark : QuranDesignColors.parchmentBg;

    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            border: Border.all(color: QuranDesignColors.woodBorder, width: 2.5),
          ),
          child: Column(
            children: [
              _RibbonTitle(title: title),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
                  child: builder(context, scrollController),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RibbonTitle extends StatelessWidget {
  final String title;
  const _RibbonTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: QuranDesignColors.ribbonTeal,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Scheherazade',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// قائمة داكنة (كحلية) بأزرار بيضاوية بحدود مضيئة — تُستخدم لقائمة
/// اختيار "القرآن مطبوع / التفسير / معاني الكلمات / سبب النزول" عند فتح
/// قسم القرآن الكريم لأول مرة
class NavyMenuSheet extends StatelessWidget {
  final String title;
  final List<NavyMenuItem> items;

  const NavyMenuSheet({super.key, required this.title, required this.items});

  static Future<void> show(BuildContext context, {required String title, required List<NavyMenuItem> items}) {
    return showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: NavyMenuSheet(title: title, items: items),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 44, 20, 20),
      decoration: BoxDecoration(
        color: QuranDesignColors.navyMenuBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: QuranDesignColors.navyMenuBorder, width: 1.4),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final item in items) ...[
                _NavyMenuButton(item: item),
                const SizedBox(height: 14),
              ],
            ],
          ),
          Positioned(
            top: -30,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(color: Color(0xFFE91E8C), shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavyMenuItem {
  final String label;
  final VoidCallback onTap;
  const NavyMenuItem({required this.label, required this.onTap});
}

class _NavyMenuButton extends StatelessWidget {
  final NavyMenuItem item;
  const _NavyMenuButton({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () {
          Navigator.of(context).maybePop();
          item.onTap();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: QuranDesignColors.navyMenuBorder, width: 1.4),
          ),
          child: Text(
            item.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Scheherazade',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// شارة رقم الآية على هيئة زخرفة نجمية (وردة عثمانية): حقل فاتح، إطار ذهبي
/// داكن، ورقم بلون أخضر غامق — تباين عالٍ ليُقرأ الرقم بوضوح على أي خلفية
class AyahRosetteBadge extends StatelessWidget {
  /// الحشو الأفقي الكلي حول الشارة (يُستخدم أيضًا لحساب عرض السطر)
  static const double badgeHorizontalPadding = 6;

  final int number;
  final bool isBookmarked;
  final bool isSelected;
  final double size;

  const AyahRosetteBadge({
    super.key,
    required this.number,
    this.isBookmarked = false,
    this.isSelected = false,
    this.size = 30,
  });

  @override
  Widget build(BuildContext context) {
    final Color fill;
    final Color stroke;
    final Color numberColor;
    if (isSelected) {
      fill = const Color(0xFF1B5E20);
      stroke = const Color(0xFFD4A843);
      numberColor = Colors.white;
    } else if (isBookmarked) {
      fill = const Color(0xFFD4A843);
      stroke = const Color(0xFF7A5200);
      numberColor = const Color(0xFF2B1B00);
    } else {
      fill = const Color(0xFFFFF1C4);
      stroke = const Color(0xFF8A5A00);
      numberColor = const Color(0xFF14501B);
    }

    final digits = toEasternArabicDigits(number);
    final fontScale = digits.length >= 3 ? 0.36 : 0.46;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: badgeHorizontalPadding / 2),
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RosettePainter(fill: fill, stroke: stroke),
          child: Center(
            child: SizedBox(
              width: size * 0.62,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  digits,
                  style: TextStyle(
                    fontFamily: 'Scheherazade',
                    fontSize: size * fontScale,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                    color: numberColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RosettePainter extends CustomPainter {
  final Color fill;
  final Color stroke;
  const _RosettePainter({required this.fill, required this.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.width / 2;
    final innerR = outerR * 0.66;
    const petals = 8;

    final path = Path();
    for (int i = 0; i < petals * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = (i * math.pi / petals) - math.pi / 2;
      final point = Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    final strokeWidth = math.max(1.2, size.width / 20);
    canvas.drawPath(path, Paint()..color = fill..style = PaintingStyle.fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = strokeWidth,
    );
    // حلقة داخلية رقيقة تُكمل الزخرفة
    canvas.drawCircle(
      center,
      innerR * 0.92,
      Paint()
        ..color = stroke.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.8, size.width / 40),
    );
  }

  @override
  bool shouldRepaint(covariant _RosettePainter oldDelegate) =>
      oldDelegate.fill != fill || oldDelegate.stroke != stroke;
}

/// شريط اسم السورة الزخرفي — إطار بأطراف مزخرفة والاسم في المنتصف
class SurahNameBanner extends StatelessWidget {
  final String surahName;
  const SurahNameBanner({super.key, required this.surahName});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF1B5E20), width: 1.6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          _bannerFlourish(),
          Expanded(
            child: Center(
              child: Text(
                'سورة $surahName',
                style: const TextStyle(
                  fontFamily: 'Scheherazade',
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ),
          ),
          _bannerFlourish(),
        ],
      ),
    );
  }

  Widget _bannerFlourish() {
    return Container(
      width: 34,
      alignment: Alignment.center,
      child: const Icon(Icons.circle, size: 6, color: Color(0xFFD4A843)),
    );
  }
}

/// أيقونة "مكية" — كعبة مبسّطة (مكعب أسود بحزام ذهبي)
class KaabaIcon extends StatelessWidget {
  final double size;
  const KaabaIcon({super.key, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _KaabaPainter()),
    );
  }
}

class _KaabaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(size.width * 0.08, size.height * 0.1, size.width * 0.84, size.height * 0.8);
    final body = Paint()..color = const Color(0xFF1A1A1A);
    canvas.drawRect(rect, body);
    final beltRect = Rect.fromLTWH(rect.left, rect.top + rect.height * 0.35, rect.width, rect.height * 0.16);
    final belt = Paint()..color = const Color(0xFFD4A843);
    canvas.drawRect(beltRect, belt);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// أيقونة "مدنية" — قبة خضراء مبسّطة
class MedinanDomeIcon extends StatelessWidget {
  final double size;
  const MedinanDomeIcon({super.key, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _DomePainter()),
    );
  }
}

class _DomePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF2E7D32);
    final domeRect = Rect.fromLTWH(size.width * 0.15, size.height * 0.1, size.width * 0.7, size.height * 0.6);
    canvas.drawArc(domeRect, 3.14159265, 3.14159265, true, paint);
    final baseRect = Rect.fromLTWH(size.width * 0.1, size.height * 0.55, size.width * 0.8, size.height * 0.35);
    canvas.drawRect(baseRect, paint);
    final finial = Paint()..color = const Color(0xFFD4A843);
    canvas.drawCircle(Offset(size.width / 2, size.height * 0.08), size.width * 0.06, finial);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// إطار حواري (Dialog) بنفس شكل اللفافة الورقية وشريط العنوان — يُستخدم
/// لنافذة "ضبط" وقوائم الاختيار الصغيرة
class OrnateDialogFrame extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget> actions;

  const OrnateDialogFrame({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget child,
    List<Widget> actions = const [],
  }) {
    return showDialog<T>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        child: OrnateDialogFrame(title: title, actions: actions, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? QuranDesignColors.parchmentBgDark : QuranDesignColors.parchmentBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: QuranDesignColors.woodBorder, width: 2.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RibbonTitle(title: title),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              child: child,
            ),
          ),
          if (actions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: actions,
              ),
            ),
        ],
      ),
    );
  }
}

/// زر بيضاوي مزخرف (أخضر مزرق للحفظ / أحمر للرجوع) كما في نافذة "ضبط"
class OrnateButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const OrnateButton({super.key, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: 110,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.2),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Scheherazade',
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
