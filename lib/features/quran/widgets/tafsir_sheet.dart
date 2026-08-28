import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../data/quran_repository.dart';
import '../models/ayah_model.dart';

/// نافذة التفسير - تُعرض كـ BottomSheet قابل للسحب
class TafsirSheet extends StatefulWidget {
  final AyahModel ayah;
  final TafsirType initialType;
  final ValueChanged<TafsirType> onTypeChanged;

  const TafsirSheet({
    super.key,
    required this.ayah,
    required this.initialType,
    required this.onTypeChanged,
  });

  @override
  State<TafsirSheet> createState() => _TafsirSheetState();
}

class _TafsirSheetState extends State<TafsirSheet> {
  late TafsirType _type;
  TafsirModel? _tafsir;
  bool _loading = true;
  bool _notFound = false;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading  = true;
      _notFound = false;
    });

    final result = await QuranRepository.instance.getTafsir(
      surah: widget.ayah.surah,
      ayah:  widget.ayah.ayah,
      type:  _type,
    );

    if (!mounted) return;
    setState(() {
      _tafsir   = result;
      _loading  = false;
      _notFound = result == null;
    });
  }

  void _switchType(TafsirType t) {
    if (t == _type) return;
    _type = t;
    widget.onTypeChanged(t);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize:     0.35,
      maxChildSize:     0.92,
      expand:           false,
      builder: (context, scrollController) {
        return Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusLg),
          ),
          child: Column(
            children: [
              // ===== مقبض =====
              _buildHandle(),

              // ===== رأس الشيت =====
              _buildHeader(),

              // ===== أزرار التبديل =====
              _buildTypeButtons(),

              const Divider(height: 1, thickness: 1),

              // ===== المحتوى (scrollable) =====
              Expanded(
                child: _buildContent(scrollController),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.md, 0, AppDimensions.md, AppDimensions.sm,
      ),
      child: Row(
        children: [
          const Icon(Icons.menu_book_rounded, color: AppColors.primaryGreen, size: 22),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Text(
              'تفسير الآية ${widget.ayah.ayah} - سورة ${widget.ayah.surah}',
              style: const TextStyle(
                fontFamily: 'Scheherazade',
                fontSize:   AppDimensions.fontLg,
                fontWeight: FontWeight.bold,
                color:      AppColors.primaryGreen,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.md, 0, AppDimensions.md, AppDimensions.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: _TypeButton(
              label: 'التفسير الميسر',
              isSelected: _type == TafsirType.muyassar,
              onTap: () => _switchType(TafsirType.muyassar),
            ),
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: _TypeButton(
              label: 'ابن كثير',
              isSelected: _type == TafsirType.ibnKathir,
              onTap: () => _switchType(TafsirType.ibnKathir),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ScrollController scrollController) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // نص الآية
          Container(
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(
                color: AppColors.accentGold.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              widget.ayah.text,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: 'Uthmanic',
                fontSize:   22,
                height:     1.8,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.md),

          // نص التفسير أو رسالة عدم الوجود
          if (_notFound)
            Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: const Text(
                'لم يُعثر على تفسير لهذه الآية في الملف الحالي.\n'
                'تأكد من تحميل ملفات التفسير الكاملة\n'
                'وفق تعليمات ملف QURAN_DATA_GUIDE.md',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Scheherazade',
                  fontSize:   AppDimensions.fontMd,
                  color:      AppColors.textMedium,
                  height:     1.7,
                ),
              ),
            )
          else
            Text(
              _tafsir!.text,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: 'Scheherazade',
                fontSize:   AppDimensions.fontLg,
                height:     1.9,
                color:      AppColors.textDark,
              ),
            ),

          const SizedBox(height: AppDimensions.xl),
        ],
      ),
    );
  }
}

// ========================================
// زر تبديل نوع التفسير
// ========================================
class _TypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primaryGreen : AppColors.bgPattern,
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm + 2),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Scheherazade',
              fontSize:   AppDimensions.fontSm,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textMedium,
            ),
          ),
        ),
      ),
    );
  }
}

// ========================================
// نافذة معاني الكلمات
// ========================================
class WordMeaningsSheet extends StatelessWidget {
  final AyahModel ayah;
  final List<WordMeaningModel> meanings;

  const WordMeaningsSheet({
    super.key,
    required this.ayah,
    required this.meanings,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize:     0.3,
      maxChildSize:     0.85,
      expand:           false,
      builder: (context, scrollController) {
        return Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusLg),
          ),
          child: Column(
            children: [
              // مقبض
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // رأس
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.md, 0, AppDimensions.md, AppDimensions.sm,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.translate_rounded, color: Color(0xFF6A1B9A), size: 22),
                    const SizedBox(width: AppDimensions.sm),
                    Text(
                      'معاني الكلمات - الآية ${ayah.ayah}',
                      style: const TextStyle(
                        fontFamily: 'Scheherazade',
                        fontSize:   AppDimensions.fontLg,
                        fontWeight: FontWeight.bold,
                        color:      Color(0xFF6A1B9A),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),

              // قائمة الكلمات
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppDimensions.md),
                  itemCount: meanings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.sm),
                  itemBuilder: (context, i) {
                    final m = meanings[i];
                    return Container(
                      padding: const EdgeInsets.all(AppDimensions.md),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A1B9A).withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.word,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontFamily: 'Uthmanic',
                              fontSize:   22,
                              fontWeight: FontWeight.bold,
                              color:      Color(0xFF6A1B9A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            m.meaning,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontFamily: 'Scheherazade',
                              fontSize:   AppDimensions.fontMd,
                              height:     1.7,
                              color:      AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
