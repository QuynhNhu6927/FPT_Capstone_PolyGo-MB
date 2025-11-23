import 'package:flutter/material.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../data/models/events/joined_event_model.dart';
import '../../../../data/repositories/event_repository.dart';
import '../../../../../core/localization/app_localizations.dart';

class HeaderSection extends StatelessWidget {
  final JoinedEventModel event;
  final String? currentUserId;
  final EventRepository eventRepository;
  final String token;
  final BuildContext parentContext;
  final VoidCallback? onCancel;
  final VoidCallback? onEventCanceled;

  const HeaderSection({
    super.key,
    required this.event,
    required this.currentUserId,
    required this.eventRepository,
    required this.token,
    required this.parentContext,
    this.onCancel,
    this.onEventCanceled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final secondaryText = isDark ? Colors.grey[400] : Colors.grey[600];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            event.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: st(context, 18),
              color: textColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.close, size: 24, color: secondaryText),
        ),
      ],
    );
  }
}
