import 'package:flutter/material.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/coming_soon_body.dart';
import '../../../core/constants/app_strings.dart';

class Tasmee3Page extends StatelessWidget {
  const Tasmee3Page({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: AppStrings.tasmee3),
      body: ComingSoonBody(
        sectionName: AppStrings.tasmee3,
        icon: Icons.mic_rounded,
        color: Color(0xFF6A1B9A),
      ),
    );
  }
}
