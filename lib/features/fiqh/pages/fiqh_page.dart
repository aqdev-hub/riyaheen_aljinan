import 'package:flutter/material.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/coming_soon_body.dart';
import '../../../core/constants/app_strings.dart';

class FiqhPage extends StatelessWidget {
  const FiqhPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: AppStrings.fiqh),
      body: ComingSoonBody(
        sectionName: AppStrings.fiqh,
        icon: Icons.balance_rounded,
        color: Color(0xFF4E342E),
      ),
    );
  }
}
