import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../data/quran_repository.dart';
import '../models/ayah_model.dart';
import '../models/surah_model.dart';
import '../providers/quran_settings_provider.dart';
import '../widgets/ayah_widget.dart';
import '../widgets/tafsir_sheet.dart';

class SurahReadingPage extends StatefulWidget {
  final int surahNumber;
  final int? scrollToAyah;

  const SurahReadingPage({
    super.key,
    required this.surahNumber,
    this.scrollToAyah,
  });

  @override
  State<SurahReadingPage> createState() => _SurahReadingPageState();
}

class _SurahReadingPageState extends State<SurahReadingPage> {
  late int _currentSurah;
  SurahModel? _surahInfo;
  List<AyahModel> _ayahs = [];
  bool _loading = true;
  String? _error;

  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _ayahKeys = {};

  @override
  void initState() {
    super.initState();
    _currentSurah = widget.surahNumber;
    _loadSurah();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSurah() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final repo  = QuranRepository.instance;
      final info  = await repo.getSurahByNumber(_currentSurah);
      final ayahs = await repo.getAyahsForSurah(_currentSurah);

      _ayahKeys.clear();
      for (final a in ayahs) {
        _ayahKeys[a.ayah] = GlobalKey();
      }

      if (!mounted) return;
      setState(() {
        _surahInfo = info;
        _ayahs     = ayahs;
        _loading   = false;
      });

      if (widget.scrollToAyah != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToAyah(widget.scrollToAyah!);
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error   = e.toString();
        _loading = false;
      });
    }
  }

  void _scrollToAyah(int ayahNumber) {
    final key = _ayahKeys[ayahNumber];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.2,
      );
    }
  }

  void _goToSurah(int number) {
    if (number < 1 || number > 114) return;
    _scrollController.jumpTo(0);
    setState(() => _currentSurah = number);
    _loadSurah();
  }

  // ========================================
  // إجراءات الآية
  // ========================================
  Future<void> _showAyahActions(AyahModel ayah) async {
    final settings = context.read<QuranSettingsProvider>();
    final hasWM    = await QuranRepository.instance.hasWordMeanings(ayah.surah, ayah.ayah);
    if (!mounted) return;

    // ✅ استخدام Navigator.of(context) الصحيح
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,          // ✅ مهم: يستخدم root navigator الذي يملك MaterialLocalizations
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLg)),
      ),
      builder: (sheetCtx) => AyahActionsSheet(
        ayah: ayah,
        isBookmarked: settings.isBookmarked(ayah.surah, ayah.ayah),
        hasWordMeanings: hasWM,
        onShowTafsir:        () => _showTafsir(ayah),
        onShowWordMeanings:  hasWM ? () => _showWordMeanings(ayah) : null,
        onCopy:              () => _copyAyah(ayah),
        onShare:             () => _shareAyah(ayah),
        onToggleBookmark:    () => settings.toggleBookmark(ayah.surah, ayah.ayah),
      ),
    );
  }

  void _showTafsir(AyahModel ayah) {
    if (!mounted) return;
    final settings = context.read<QuranSettingsProvider>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,           // ✅
      backgroundColor: Colors.transparent,
      builder: (_) => TafsirSheet(
        ayah: ayah,
        initialType: settings.tafsirType,
        onTypeChanged: settings.setTafsirType,
      ),
    );
  }

  Future<void> _showWordMeanings(AyahModel ayah) async {
    final meanings = await QuranRepository.instance.getWordMeanings(
      surah: ayah.surah,
      ayah:  ayah.ayah,
    );
    if (!mounted || meanings.isEmpty) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,           // ✅
      backgroundColor: Colors.transparent,
      builder: (_) => WordMeaningsSheet(ayah: ayah, meanings: meanings),
    );
  }

  void _copyAyah(AyahModel ayah) {
    Clipboard.setData(ClipboardData(text: ayah.text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الآية', style: TextStyle(fontFamily: 'Scheherazade')),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareAyah(AyahModel ayah) {
    final surahName = _surahInfo?.name ?? '';
    final text = '${ayah.text}\n\n﴿ سورة $surahName - آية ${ayah.ayah} ﴾';
    Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الآية للمشاركة', style: TextStyle(fontFamily: 'Scheherazade')),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ========================================
  // Build
  // ========================================
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<QuranSettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgPattern,
      // ✅ لا نستخدم SafeArea هنا لأنها تسبب مشاكل مع SliverAppBar
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _buildBody(settings),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ========================================
  // الهيدر
  // ========================================
  Widget _buildHeader(BuildContext context) {
    // نحسب ارتفاع status bar يدوياً
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(
        top: topPadding + AppDimensions.xs,
        bottom: AppDimensions.sm,
        left: AppDimensions.sm,
        right: AppDimensions.sm,
      ),
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: Row(
        children: [
          // زر الرجوع
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).maybePop(),
          ),

          // معلومات السورة
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _surahInfo != null ? 'سورة ${_surahInfo!.name}' : '',
                  style: const TextStyle(
                    fontFamily: 'Scheherazade',
                    fontSize:   AppDimensions.fontXl,
                    fontWeight: FontWeight.bold,
                    color:      Colors.white,
                  ),
                ),
                if (_surahInfo != null)
                  Text(
                    '${_surahInfo!.revelationLabel} • ${_surahInfo!.ayahCount} آية',
                    style: TextStyle(
                      fontFamily: 'Scheherazade',
                      fontSize:   AppDimensions.fontXs,
                      color:      Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          ),

          // زر إعدادات الخط
          IconButton(
            icon: const Icon(Icons.text_fields_rounded, color: Colors.white, size: 20),
            onPressed: _showFontSizeSheet,
          ),
        ],
      ),
    );
  }

  void _showFontSizeSheet() {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,       // ✅
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLg)),
      ),
      builder: (_) => Consumer<QuranSettingsProvider>(
        builder: (ctx, s, __) => Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.lg, AppDimensions.md, AppDimensions.lg, AppDimensions.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: AppDimensions.md),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'حجم الخط',
                style: TextStyle(
                  fontFamily: 'Scheherazade',
                  fontSize:   AppDimensions.fontLg,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.md),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.primaryGreen),
                    onPressed: s.decreaseFontSize,
                  ),
                  Expanded(
                    child: Slider(
                      value: s.fontSize,
                      min: QuranSettingsProvider.minFontSize,
                      max: QuranSettingsProvider.maxFontSize,
                      divisions: 11,
                      activeColor: AppColors.primaryGreen,
                      onChanged: s.setFontSize,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryGreen),
                    onPressed: s.increaseFontSize,
                  ),
                ],
              ),
              // معاينة حجم الخط
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: AppColors.bgPattern,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Text(
                  'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Uthmanic',
                    fontSize:   s.fontSize,
                    height:     1.8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========================================
  // المحتوى الرئيسي
  // ========================================
  Widget _buildBody(QuranSettingsProvider settings) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_ayahs.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // البسملة
          if (_currentSurah != 9 && _currentSurah != 1)
            _buildBasmala(),

          // نص السورة
          _buildAyahsContainer(settings),

          const SizedBox(height: AppDimensions.xl),
        ],
      ),
    );
  }

  Widget _buildBasmala() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.md,
        horizontal: AppDimensions.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.3)),
      ),
      child: const Text(
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Uthmanic',
          fontSize:   26,
          color:      AppColors.primaryGreen,
          height:     1.6,
        ),
      ),
    );
  }

  Widget _buildAyahsContainer(QuranSettingsProvider settings) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _buildAyahsFlow(settings),
    );
  }

  /// ✅ الإصلاح الجوهري لمشكلة Layout الأصفر:
  /// استخدام RichText مع WidgetSpan بشكل صحيح
  Widget _buildAyahsFlow(QuranSettingsProvider settings) {
    final spans = <InlineSpan>[];

    for (final ayah in _ayahs) {
      final isBookmarked = settings.isBookmarked(ayah.surah, ayah.ayah);
      final key = _ayahKeys[ayah.ayah] ?? GlobalKey();

      // نص الآية
      spans.add(
        TextSpan(
          text: '${ayah.text} ',
          style: TextStyle(
            fontFamily: 'Uthmanic',
            fontSize:   settings.fontSize,
            height:     2.0,
            color:      Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : AppColors.textDark,
          ),
        ),
      );

      // شارة رقم الآية (WidgetSpan)
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: GestureDetector(
            key: key,
            onTap: () {
              context.read<QuranSettingsProvider>().setLastRead(ayah.surah, ayah.ayah);
              _showAyahActions(ayah);
            },
            child: AyahNumberBadge(
              number: ayah.ayah,
              isBookmarked: isBookmarked,
            ),
          ),
        ),
      );

      spans.add(const TextSpan(text: '  '));
    }

    return RichText(
      textAlign:     TextAlign.justify,
      textDirection: TextDirection.rtl,
      text: TextSpan(children: spans),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 56, color: AppColors.wrong),
            const SizedBox(height: AppDimensions.md),
            const Text(
              'تعذّر تحميل السورة',
              style: TextStyle(
                fontFamily: 'Scheherazade',
                fontSize:   AppDimensions.fontXl,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              'تأكد من وجود ملف quran_text.json\nفي assets/data/quran/',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Scheherazade',
                fontSize:   AppDimensions.fontMd,
                color:      AppColors.textLight,
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            ElevatedButton.icon(
              onPressed: _loadSurah,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Scheherazade')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'لا توجد آيات\nتأكد من ملف quran_text.json',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Scheherazade',
          fontSize:   AppDimensions.fontLg,
          color:      AppColors.textLight,
        ),
      ),
    );
  }

  // ========================================
  // الشريط السفلي
  // ========================================
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical:   AppDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      // ✅ SafeArea هنا فقط للـ bottom navigation bar
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // ← السورة السابقة (رقم أصغر)
            if (_currentSurah > 1)
              Expanded(
                child: _NavButton(
                  icon: Icons.arrow_forward_rounded,
                  label: 'السابقة',
                  onTap: () => _goToSurah(_currentSurah - 1),
                  alignEnd: false,
                ),
              )
            else
              const Expanded(child: SizedBox()),

            // حفظ موضع القراءة
            IconButton(
              icon: const Icon(Icons.bookmark_add_outlined, color: AppColors.accentGold),
              tooltip: 'حفظ آخر موضع',
              onPressed: () {
                if (_ayahs.isNotEmpty) {
                  context.read<QuranSettingsProvider>()
                      .setLastRead(_currentSurah, _ayahs.first.ayah);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'تم حفظ موضع القراءة',
                        style: TextStyle(fontFamily: 'Scheherazade'),
                      ),
                      behavior:        SnackBarBehavior.floating,
                      backgroundColor: AppColors.primaryGreen,
                      duration:        Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),

            // → السورة التالية (رقم أكبر)
            if (_currentSurah < 114)
              Expanded(
                child: _NavButton(
                  icon: Icons.arrow_back_rounded,
                  label: 'التالية',
                  onTap: () => _goToSurah(_currentSurah + 1),
                  alignEnd: true,
                ),
              )
            else
              const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }

  // ========================================
  // خريطة بداية الأجزاء
  // ========================================
  static const Map<int, (int, int)> _juzStartMap = {
    1: (1, 1),    2: (2, 142),  3: (2, 253),  4: (3, 92),
    5: (4, 24),   6: (4, 148),  7: (5, 82),   8: (6, 111),
    9: (7, 88),   10: (8, 41),  11: (9, 93),  12: (11, 6),
    13: (12, 53), 14: (15, 1),  15: (17, 1),  16: (18, 75),
    17: (21, 1),  18: (23, 1),  19: (25, 21), 20: (27, 56),
    21: (29, 46), 22: (33, 31), 23: (36, 28), 24: (39, 32),
    25: (41, 47), 26: (46, 1),  27: (51, 31), 28: (58, 1),
    29: (67, 1),  30: (78, 1),
  };
}

// ========================================
// زر التنقل
// ========================================
class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool alignEnd;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.alignEnd,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      Icon(icon, size: 18, color: AppColors.primaryGreen),
      const SizedBox(width: 6),
      Text(
        label,
        style: const TextStyle(
          fontFamily: 'Scheherazade',
          fontSize:   AppDimensions.fontSm,
          fontWeight: FontWeight.w600,
          color:      AppColors.primaryGreen,
        ),
      ),
    ];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical:   AppDimensions.sm,
          horizontal: AppDimensions.sm,
        ),
        child: Row(
          mainAxisAlignment: alignEnd
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: alignEnd ? children.reversed.toList() : children,
        ),
      ),
    );
  }
}
