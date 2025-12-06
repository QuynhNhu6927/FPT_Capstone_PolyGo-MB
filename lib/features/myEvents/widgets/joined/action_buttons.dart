import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/events/joined_event_model.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../routes/app_routes.dart';
import '../../../rating/screens/rating_screen.dart';
import '../../../rating/screens/rates_screen.dart';
import '../../../shared/share_event_dialog.dart';
import '../event_summary.dart';

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
          size: ButtonSize.sm,
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

    if (isHost) {
      // 1) Completed → Rate + Summary
      if (eventStatus == 'completed') {
        if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 8));

        buttons.add(
          AppButton(
            variant: ButtonVariant.outline,
            size: ButtonSize.sm,
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

        buttons.add(const SizedBox(width: 8));

        buttons.add(
          AppButton(
            text: 'AI Summary',
            variant: ButtonVariant.primary,
            size: ButtonSize.sm,
            icon: const Icon(Icons.smart_toy_outlined, size: 18),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EventSummary(
                    eventId: event.id,
                    token: token,
                    isHost: isHost,
                  ),
                ),
              );
            },
          ),
        );
      }

      // 2) Approved / Live → Start / Join / Wait
      if (event.status == 'Approved' || eventStatus == 'live') {
        if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 8));

        final now = DateTime.now();
        final isEventStarted = now.isAfter(event.startAt);
        final isLive = eventStatus == 'live';

        final buttonText =
        isLive ? loc.translate('join')
            : isEventStarted ? loc.translate('start')
            : loc.translate('wait');

        final canJoin = isLive || isEventStarted;

        buttons.add(
          AppButton(
            text: buttonText,
            size: ButtonSize.sm,
            icon: Icon(
              isLive ? Icons.login : Icons.access_time,
              size: 18,
              color: canJoin ? null : Colors.grey[400],
            ),
            onPressed: canJoin
                ? () {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.eventWaiting,
                arguments: {
                  'eventId': event.id,
                  'eventTitle': event.title,
                  'eventStatus': event.status,
                  'isHost': true,
                  'hostId': event.host.id,
                  'hostName': event.host.name,
                  'startAt': event.startAt,
                  'sourceLanguage': event.language.code,
                },
              );
            }
                : null,
            variant: canJoin ? ButtonVariant.primary : ButtonVariant.outline,
            color: canJoin
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300],
          ),
        );
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: buttons,
      );
    }

    /// ---------------- Join button ----------------
    if (eventStatus == 'live') {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 8));
      buttons.add(
        AppButton(
          text: loc.translate('join'),
          size: ButtonSize.sm,
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
                'sourceLanguage': event.language.code,
              },
            );
          },
        ),
      );
    }

    /// ---------------- Join button ----------------
    if (eventStatus == 'approved') {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 8));
      buttons.add(
        AppButton(
          text: loc.translate('wait_for_host'),
          size: ButtonSize.sm,
          icon: const Icon(Icons.lock_clock, size: 18),
          variant: ButtonVariant.outline,
        ),
      );
    }

    /// ---------------- Rating buttons ----------------
    if (eventStatus == 'completed') {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 8));

      if (isHost || (hasRating ?? false)) {
        buttons.add(
          AppButton(
            size: ButtonSize.sm,
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
            size: ButtonSize.sm,
            variant: ButtonVariant.outline,
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
      buttons.add(const SizedBox(width: 8));
      buttons.add(
        AppButton(
          text: 'AI Summary',
          variant: ButtonVariant.primary,
          size: ButtonSize.sm,
          icon: const Icon(
            Icons.smart_toy_outlined,
            size: 18,
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EventSummary(
                  eventId: event.id,
                  token: token,
                  isHost: isHost,
                ),
              ),
            );
          },
        ),
      );

    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: buttons,
    );
  }
}
