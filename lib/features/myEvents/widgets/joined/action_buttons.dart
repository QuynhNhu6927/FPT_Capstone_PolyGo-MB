import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
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
    final loc = AppLocalizations.of(context);

    List<Widget> buttons = [];

    /// ---------------- Share button ----------------
    final canShare = event.isPublic && eventStatus != 'cancelled';
    if (canShare) {

      buttons.add(
        AppButton(
          variant: ButtonVariant.outline,
          size: ButtonSize.md,
          icon: const Icon(Icons.share_outlined, size: 18),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => ShareEventDialog(targetId: event.id),
            );
          },
        ),
      );
    }

    /// ---------------- Join button ----------------
    if (eventStatus == 'live') {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 12));
      buttons.add(
        AppButton(
          text: loc.translate('join'),
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
        ),
      );
    }

    /// ---------------- Join button ----------------
    if (eventStatus == 'approved') {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 12));
      buttons.add(
        AppButton(
          text: loc.translate('wait_for_host'),
          size: ButtonSize.md,
          icon: const Icon(Icons.lock_clock, size: 18),
          variant: ButtonVariant.outline,
        ),
      );
    }

    /// ---------------- Rating buttons ----------------
    if (eventStatus == 'completed') {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 12));

      if (isHost || (hasRating ?? false)) {
        buttons.add(
          AppButton(
            text: loc.translate('rating'),
            size: ButtonSize.md,
            variant: ButtonVariant.outline,
            icon: const Icon(Icons.star_outline, size: 18),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RatesScreen(eventId: event.id),
                ),
              );
            },
          ),
        );
      } else {
        buttons.add(
          AppButton(
            text: loc.translate('rate'),
            size: ButtonSize.md,
            variant: ButtonVariant.primary,
            icon: const Icon(Icons.star_rate_outlined, size: 18),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RatingScreen(eventId: event.id),
                ),
              );
            },
          ),
        );
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: buttons,
    );
  }
}
