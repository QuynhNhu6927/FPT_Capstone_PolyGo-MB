import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/responsive.dart';
import '../../../core/utils/render_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/models/events/joined_event_model.dart';
import '../../../data/repositories/event_repository.dart';
import '../../../routes/app_routes.dart';
import '../../rating/screens/rates_screen.dart';
import '../../rating/screens/rating_screen.dart';
import '../../shared/share_event_dialog.dart';
import 'hosted_user_list.dart';

class JoinedEventDetails extends StatefulWidget {
  final JoinedEventModel event;
  final String? currentUserId;
  final EventRepository eventRepository;
  final String token;
  final BuildContext parentContext;
  final VoidCallback? onCancel;
  final VoidCallback? onEventCanceled;

  const JoinedEventDetails({
    super.key,
    required this.event,
    required this.eventRepository,
    required this.token,
    required this.parentContext,
    this.currentUserId,
    this.onCancel,
    this.onEventCanceled,
  });

  @override
  State<JoinedEventDetails> createState() => _JoinedEventDetailsState();
}

class _JoinedEventDetailsState extends State<JoinedEventDetails> {
  bool? hasRating;

  @override
  void initState() {
    super.initState();
    fetchMyRating();
  }

  Future<void> fetchMyRating() async {
    try {
      final myRating = await widget.eventRepository.getMyRating(
        token: widget.token,
        eventId: widget.event.id,
      );
      if (!mounted) return;

      setState(() {
        hasRating = myRating?.hasRating ?? false;
      });
    } catch (e) {
      setState(() {
        hasRating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    final dividerColor = isDark ? Colors.grey[700] : Colors.grey[300];
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final secondaryText = isDark ? Colors.grey[400] : Colors.grey[600];
    final eventLocal = widget.event.startAt.toLocal();
    final dateFormatted = DateFormat('dd MMM yyyy, HH:mm').format(eventLocal);

    final eventStatus = widget.event.status.toLowerCase();
    final now = DateTime.now();
    final isHost = widget.currentUserId == widget.event.host.id;
    final isEventStarted = now.isAfter(widget.event.startAt);
    Widget? actionButton;

    return Dialog(
          elevation: 12,
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(sw(context, 16)),
          ),
          shadowColor: Colors.black.withOpacity(0.3),
          child: Container(
            padding: EdgeInsets.all(sw(context, 20)),
            width: sw(context, 500),
            constraints: BoxConstraints(maxHeight: sh(context, 650)),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.event.title,
                          style: t.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: st(context, 18),
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.close,
                          size: 24,
                          color: secondaryText ?? Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(color: dividerColor, thickness: 1),
                  const SizedBox(height: 16),

                  // --- Banner ---
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: widget.event.bannerUrl.isNotEmpty
                        ? Image.network(
                            widget.event.bannerUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(
                                  Icons.event_note_rounded,
                                  size: 64,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey[400],
                            child: const Center(
                              child: Icon(
                                Icons.event_note_rounded,
                                size: 64,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // --- Host info ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.userProfile,
                            arguments: {'id': widget.event.host.id},
                          );
                        },
                        child: CircleAvatar(
                          radius: sw(context, 28),
                          backgroundColor: Colors.grey[300],
                          backgroundImage:
                              (widget.event.host.avatarUrl != null &&
                                  widget.event.host.avatarUrl!.isNotEmpty)
                              ? NetworkImage(widget.event.host.avatarUrl!)
                              : null,
                          child:
                              (widget.event.host.avatarUrl == null ||
                                  widget.event.host.avatarUrl!.isEmpty)
                              ? const Icon(
                                  Icons.person,
                                  size: 36,
                                  color: Colors.white70,
                                )
                              : null,
                        ),
                      ),

                      SizedBox(width: sw(context, 12)),

                      // --- Name + "host" clickable ---
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.userProfile,
                              arguments: {'id': widget.event.host.id},
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.event.host.name,
                                style: t.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: st(context, 15),
                                  color: textColor,
                                ),
                              ),
                              Text(
                                loc.translate('host'),
                                style: t.bodySmall?.copyWith(
                                  color: secondaryText,
                                  fontSize: st(context, 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // --- Cancel/Unregister ---
                      if (widget.event.status != "Completed" &&
                          widget.event.status != "Cancelled" &&
                          widget.event.status != "Live")
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: secondaryText),
                          position: PopupMenuPosition.under,
                          offset: const Offset(-16, 8),
                          onSelected: (value) async {
                            if (value == 'cancel') {
                              final reasonController = TextEditingController();
                              String? errorText;

                              await showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (dialogContext) {
                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return AlertDialog(
                                        title: Text(
                                          loc.translate('confirm_cancel'),
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              loc.translate(
                                                'enter_cancel_reason',
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            TextField(
                                              controller: reasonController,
                                              maxLines: 3,
                                              decoration: InputDecoration(
                                                hintText: loc.translate(
                                                  'cancel_reason_placeholder',
                                                ),
                                                border:
                                                    const OutlineInputBorder(),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                errorText: errorText,
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(dialogContext),
                                            child: Text(loc.translate('no')),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              final reason = reasonController
                                                  .text
                                                  .trim();
                                              if (reason.isEmpty) {
                                                setState(() {
                                                  errorText = loc.translate(
                                                    'enter_reason_first',
                                                  );
                                                });
                                                return;
                                              }

                                              try {
                                                final isHost =
                                                    widget.currentUserId ==
                                                    widget.event.host.id;

                                                final res = isHost
                                                    ? await widget
                                                          .eventRepository
                                                          .cancelEvent(
                                                            token: widget.token,
                                                            eventId:
                                                                widget.event.id,
                                                            reason: reason,
                                                          )
                                                    : await widget
                                                          .eventRepository
                                                          .unregisterEvent(
                                                            token: widget.token,
                                                            eventId:
                                                                widget.event.id,
                                                            reason: reason,
                                                          );

                                                if (!mounted) return;

                                                Navigator.of(
                                                  context,
                                                  rootNavigator: true,
                                                ).pop();
                                                Navigator.pop(context);

                                                widget.onCancel?.call();
                                                widget.onEventCanceled?.call();

                                                ScaffoldMessenger.of(
                                                  widget.parentContext,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      res?.message ??
                                                          (isHost
                                                              ? loc.translate(
                                                                  'cancel_success',
                                                                )
                                                              : loc.translate(
                                                                  'unregister_success',
                                                                )),
                                                    ),
                                                  ),
                                                );
                                              } catch (_) {
                                                if (mounted)
                                                  Navigator.of(
                                                    context,
                                                    rootNavigator: true,
                                                  ).pop();
                                                ScaffoldMessenger.of(
                                                  widget.parentContext,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      loc.translate(
                                                        'cancel_too_late',
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Text(loc.translate('yes')),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                            }
                          },
                          itemBuilder: (ctx) => [
                            PopupMenuItem(
                              value: 'cancel',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.cancel_outlined,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    loc.translate('cancel'),
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- Description ---
                  RenderUtils.selectableMarkdownText(
                    context,
                    widget.event.description.isNotEmpty
                        ? widget.event.description
                        : loc.translate('no_description'),
                    style: TextStyle(
                      fontSize: st(context, 14),
                      height: 1.4,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Info rows ---
                  _buildInfoRow(
                    context,
                    Icons.language,
                    loc.translate('language'),
                    widget.event.language.name,
                    textColor,
                    secondaryText,
                  ),
                  _buildInfoRow(
                    context,
                    Icons.category_outlined,
                    loc.translate('categories'),
                    widget.event.categories.isNotEmpty
                        ? widget.event.categories.map((e) => e.name).join(', ')
                        : loc.translate('none'),
                    textColor,
                    secondaryText,
                  ),
                  _buildInfoRow(
                    context,
                    Icons.people_alt_outlined,
                    loc.translate('participants'),
                    "${widget.event.numberOfParticipants}/${widget.event.capacity}",
                    textColor,
                    secondaryText,
                    onTapValue: widget.currentUserId == widget.event.host.id
                        ? () async {
                            try {
                              final eventDetails = await widget.eventRepository
                                  .getEventDetails(
                                    token: widget.token,
                                    eventId: widget.event.id,
                                  );

                              if (!mounted) return;

                              showDialog(
                                context: context,
                                builder: (_) => HostedUserList(
                                  participants: eventDetails!.participants,
                                  hostId: widget.event.host.id,
                                  token: widget.token,
                                  eventId: widget.event.id,
                                  eventRepository: widget.eventRepository,
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    loc.translate('error_occurred'),
                                  ),
                                ),
                              );
                            }
                          }
                        : null,
                  ),
                  _buildInfoRow(
                    context,
                    Icons.access_time,
                    loc.translate('time'),
                    dateFormatted,
                    textColor,
                    secondaryText,
                  ),

                  const SizedBox(height: 16),
                  Divider(color: dividerColor, thickness: 1),
                  const SizedBox(height: 16),

                  // --- Bottom buttons ---
                  Builder(
                    builder: (context) {
                      Widget? actionButton;

                      switch (eventStatus) {
                        case 'approved':
                          if (isEventStarted) {
                            actionButton = AppButton(
                              text: isHost
                                  ? loc.translate('start')
                                  : loc.translate('join'),
                              size: ButtonSize.md,
                              icon: const Icon(
                                Icons.meeting_room_outlined,
                                size: 18,
                              ),
                              variant: ButtonVariant.primary,
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.eventWaiting,
                                  arguments: {
                                    'eventId': widget.event.id,
                                    'eventTitle': widget.event.title,
                                    'eventStatus': widget.event.status,
                                    'isHost':
                                        widget.currentUserId ==
                                        widget.event.host.id,
                                    'hostId': widget.event.host.id,
                                    'hostName': widget.event.host.name,
                                    'startAt': widget.event.startAt,
                                    'initialMic': true,
                                  },
                                );
                              },
                            );
                          } else {
                            actionButton = AppButton(
                              text: loc.translate('wait'),
                              size: ButtonSize.md,
                              icon: Icon(
                                Icons.access_time,
                                size: 18,
                                color: Colors.grey[400],
                              ),
                              variant: ButtonVariant.outline,
                              onPressed: null,
                              color: Colors.grey[300],
                            );
                          }
                          break;

                        case 'live':
                          actionButton = AppButton(
                            text: loc.translate('join'),
                            size: ButtonSize.md,
                            icon: const Icon(
                              Icons.meeting_room_outlined,
                              size: 18,
                            ),
                            variant: ButtonVariant.primary,
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.eventWaiting,
                                arguments: {
                                  'eventId': widget.event.id,
                                  'eventTitle': widget.event.title,
                                  'eventStatus': widget.event.status,
                                  'isHost':
                                      widget.currentUserId ==
                                      widget.event.host.id,
                                  'hostId': widget.event.host.id,
                                  'hostName': widget.event.host.name,
                                  'initialMic': true,
                                },
                              );
                            },
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
                                builder: (_) =>
                                    ShareEventDialog(targetId: widget.event.id),
                              );
                            },
                          );
                          break;

                        case 'cancelled':
                        case 'rejected':
                          actionButton = null;
                          break;

                        default:
                          actionButton = null;
                      }

                      // --- Build Row with additional Rate/View Rating button ---
                      List<Widget> buttons = [];

                      if (actionButton != null) {
                        // Nếu event completed, actionButton là share
                        buttons.add(actionButton);
                      }

                      if (eventStatus == 'completed') {
                        if (isHost) {
                          // Host luôn xem rating
                          buttons.add(const SizedBox(width: 12));
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
                                    builder: (_) =>
                                        RatesScreen(eventId: widget.event.id),
                                  ),
                                );
                              },
                            ),
                          );
                        } else {
                          // Không phải host
                          buttons.add(const SizedBox(width: 12));
                          if (hasRating == true) {
                            // Nếu đã rate → View Rating
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
                                      builder: (_) =>
                                          RatesScreen(eventId: widget.event.id),
                                    ),
                                  );
                                },
                              ),
                            );
                          } else {
                            // Nếu chưa rate → Rate
                            buttons.add(
                              AppButton(
                                text: loc.translate('rate'),
                                size: ButtonSize.md,
                                variant: ButtonVariant.primary,
                                icon: const Icon(
                                  Icons.star_rate_outlined,
                                  size: 18,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RatingScreen(
                                        eventId: widget.event.id,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                        }
                      }

                      if (eventStatus != 'completed' && actionButton != null) {
                        buttons.insert(
                          0,
                            AppButton(
                              variant: ButtonVariant.outline,
                              size: ButtonSize.md,
                              icon: const Icon(Icons.share_outlined, size: 18),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) =>
                                      ShareEventDialog(targetId: widget.event.id),
                                );
                              },
                            ),
                        );
                        buttons.insert(1, const SizedBox(width: 12));
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: buttons,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 250.ms)
        .slide(
          begin: const Offset(0, 0.08),
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color textColor,
    Color? secondaryText, {
    VoidCallback? onTapValue,
  }) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: secondaryText),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: "$label: ",
                style: t.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: secondaryText,
                  fontSize: st(context, 14),
                ),
                children: [
                  TextSpan(
                    text: value,
                    style: t.bodyMedium?.copyWith(
                      color: onTapValue != null
                          ? Theme.of(context).colorScheme.primary
                          : textColor,
                      fontSize: st(context, 14),
                      decoration: onTapValue != null
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                    recognizer: onTapValue != null
                        ? (TapGestureRecognizer()..onTap = onTapValue)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
