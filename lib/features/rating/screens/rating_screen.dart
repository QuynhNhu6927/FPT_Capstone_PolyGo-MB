import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../widgets/rating.dart';

class RatingScreen extends StatefulWidget {
  final String eventId;

  const RatingScreen({super.key, required this.eventId});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          title: Text(loc.translate('rating_event')),
          centerTitle: true,
        ),
        body: RatingWidget(eventId: widget.eventId),
      ),
    );
  }
}
