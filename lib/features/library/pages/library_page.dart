import 'package:flutter/material.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/coming_soon_body.dart';
import '../../../core/constants/app_strings.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: AppStrings.library),
      body: ComingSoonBody(
        sectionName: AppStrings.library,
        icon: Icons.local_library_rounded,
        color: Color(0xFF37474F),
      ),
    );
  }
}
