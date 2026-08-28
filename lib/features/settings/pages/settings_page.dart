import 'package:flutter/material.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/coming_soon_body.dart';
import '../../../core/constants/app_strings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: AppStrings.settings),
      body: ComingSoonBody(
        sectionName: AppStrings.settings,
        icon: Icons.settings_rounded,
        color: Color(0xFF424242),
      ),
    );
  }
}
