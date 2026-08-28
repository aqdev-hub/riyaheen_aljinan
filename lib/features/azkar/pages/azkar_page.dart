import 'package:flutter/material.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/coming_soon_body.dart';
import '../../../core/constants/app_strings.dart';

class AzkarPage extends StatelessWidget {
  const AzkarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: AppStrings.azkar),
      body: ComingSoonBody(
        sectionName: AppStrings.azkar,
        icon: Icons.self_improvement_rounded,
        color: Color(0xFF00695C),
      ),
    );
  }
}
