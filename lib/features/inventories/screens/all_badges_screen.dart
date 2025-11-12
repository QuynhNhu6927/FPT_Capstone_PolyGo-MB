import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../shared/app_bottom_bar.dart';
import '../widgets/all_badges.dart';

class AllBadgesScreen extends StatelessWidget {
  const AllBadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          loc.translate("my_badges"),
          style: t.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: const AllBadges(),
      bottomNavigationBar: SafeArea(
        top: false,
        child: const AppBottomBar(currentIndex: 5),
      ),
    );
  }
}
