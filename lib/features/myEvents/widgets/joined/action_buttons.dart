import 'package:flutter/material.dart';
import '../../../../data/models/events/joined_event_model.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../routes/app_routes.dart';
import '../../../rating/screens/rating_screen.dart';
import '../../../rating/screens/rates_screen.dart';
import '../../../shared/share_event_dialog.dart';

class ActionButtons extends StatelessWidget {
  final JoinedEventModel event;
  final String? currentUserId;
  final bool? hasRating;
  final String token;

  const ActionButtons({
    super.key,
    required this.event,
    required this.currentUserId,
    required this.hasRating,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final eventStatus = event.status.toLowerCase();
    final isHost = currentUserId == event.host.id;

    Widget? actionButton;

    switch (eventStatus) {
      case 'approved':
        actionButton = AppButton(
          text: 'Join',
          size: ButtonSize.md,
          icon: const Icon(Icons.meeting_room_outlined, size: 18),
          variant: ButtonVariant.primary,
          onPressed: () {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.eventWaiting,
              arguments: {
                'eventId': event.id,
                'eventTitle': event.title,
                'eventStatus': event.status,
                'isHost': isHost,
                'hostId': event.host.id,
                'hostName': event.host.name,
                'initialMic': true,
              },
            );
          },
        );
        break;
      case 'live':
        actionButton = AppButton(
          text: 'Join',
          size: ButtonSize.md,
          icon: const Icon(Icons.meeting_room_outlined, size: 18),
          variant: ButtonVariant.primary,
          onPressed: () {},
        );
        break;
      case 'completed':
        actionButton = AppButton(
          variant: ButtonVariant.outline,
          size: ButtonSize.md,
          icon: const Icon(Icons.share_outlined, size: 18),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => ShareEventDialog(targetId: event.id),
            );
          },
        );
        break;
      default:
        actionButton = null;
    }

    List<Widget> buttons = [];
    if (actionButton != null) buttons.add(actionButton);

    // Rating buttons
    if (eventStatus == 'completed') {
      buttons.add(const SizedBox(width: 12));
      if (isHost || (hasRating ?? false)) {
        buttons.add(AppButton(
          text: 'Rating',
          size: ButtonSize.md,
          variant: ButtonVariant.outline,
          icon: const Icon(Icons.star_outline, size: 18),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => RatesScreen(eventId: event.id)),
            );
          },
        ));
      } else {
        buttons.add(AppButton(
          text: 'Rate',
          size: ButtonSize.md,
          variant: ButtonVariant.primary,
          icon: const Icon(Icons.star_rate_outlined, size: 18),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => RatingScreen(eventId: event.id)),
            );
          },
        ));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: buttons,
    );
  }
}
