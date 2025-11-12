import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../home/screens/home_screen.dart';
import '../../shared/app_bottom_bar.dart';
import '../widgets/overview.dart';

class OverviewScreen extends StatelessWidget {
  final String id;

  const OverviewScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          loc.translate("wordset_overview"),
          style: t.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: OverviewWidget(wordSetId: id),
      bottomNavigationBar: SafeArea(
        top: false,
        child: const AppBottomBar(currentIndex: 5),
      ),
    );
  }
}
