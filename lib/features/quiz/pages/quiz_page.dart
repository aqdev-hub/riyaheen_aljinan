import 'package:flutter/material.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/coming_soon_body.dart';
import '../../../core/constants/app_strings.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: AppStrings.quiz),
      body: ComingSoonBody(
        sectionName: AppStrings.quiz,
        icon: Icons.quiz_rounded,
        color: Color(0xFFF57F17),
      ),
    );
  }
}
