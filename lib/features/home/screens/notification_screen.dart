import 'package:flutter/material.dart' hide Notification;
import '../../../../core/localization/app_localizations.dart';
import '../widgets/notification.dart';
import '../../shared/app_bottom_bar.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          loc.translate("notifications"),
          style: t.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: const Notification(),
      bottomNavigationBar: const SafeArea(
        top: false,
        child: AppBottomBar(currentIndex: 4),
      ),
    );
  }
}
