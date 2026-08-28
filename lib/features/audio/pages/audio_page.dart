import 'package:flutter/material.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/coming_soon_body.dart';
import '../../../core/constants/app_strings.dart';

class AudioPage extends StatelessWidget {
  const AudioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: AppStrings.audioLib),
      body: ComingSoonBody(
        sectionName: AppStrings.audioLib,
        icon: Icons.headphones_rounded,
        color: Color(0xFF880E4F),
      ),
    );
  }
}
