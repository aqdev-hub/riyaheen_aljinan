import 'package:flutter/material.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/coming_soon_body.dart';
import '../../../core/constants/app_strings.dart';

class TafsirPage extends StatelessWidget {
  const TafsirPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: AppStrings.tafsir),
      body: ComingSoonBody(
        sectionName: AppStrings.tafsir,
        icon: Icons.auto_stories_rounded,
        color: Color(0xFF1565C0),
      ),
    );
  }
}
