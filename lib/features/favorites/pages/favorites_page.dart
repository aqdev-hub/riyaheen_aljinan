import 'package:flutter/material.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/coming_soon_body.dart';
import '../../../core/constants/app_strings.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: AppStrings.favorites),
      body: ComingSoonBody(
        sectionName: AppStrings.favorites,
        icon: Icons.favorite_rounded,
        color: Color(0xFFC62828),
      ),
    );
  }
}
