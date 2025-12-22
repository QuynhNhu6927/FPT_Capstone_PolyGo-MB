import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:polygo_mobile/features/myEvents/widgets/hosted/statistic_event.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../core/utils/render_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../data/models/events/event_details_model.dart';
import '../../../../data/models/events/hosted_event_model.dart';
import '../../../../data/repositories/event_repository.dart';
import '../../../../routes/app_routes.dart';
import '../../../rating/screens/rates_screen.dart';
import '../../../shared/share_event_dialog.dart';
import '../event_summary.dart';
import '../hosted/host_cancel_event_dialog.dart';
import 'hosted_user_list.dart';

class HostedEventDetails extends StatefulWidget {
  final HostedEventModel event;
  final BuildContext parentContext;
  final EventRepository eventRepository;
  final String token;
  final VoidCallback? onCancel;

  const HostedEventDetails({
    super.key,
    required this.event,
    required this.eventRepository,
    required this.token,
    required this.parentContext,
    this.onCancel,
  });

  @override
  State<HostedEventDetails> createState() => _HostedEventDetailsState();
}

class _HostedEventDetailsState extends State<HostedEventDetails> {
  int currentParticipantCount = 0;

  @override
  void initState() {
    super.initState();
    currentParticipantCount = widget.event.numberOfParticipants;
  }

  @override
  Widget build(BuildContext context) {
    late List<ParticipantModel> participants;
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    final dividerColor = isDark ? Colors.grey[700] : Colors.grey[300];
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final secondaryText = isDark ? Colors.grey[400] : Colors.black;

    final eventLocal = widget.event.startAt.toLocal();
    final dateFormatted = DateFormat('dd MMM yyyy, HH:mm').format(eventLocal);

    final durationFormatted =
        "${widget.event.expectedDurationInMinutes ~/ 60}h ${widget.event.expectedDurationInMinutes % 60}m";

    final double fontSize = st(context, 14);
    final double lineHeight = 1.4;
    final int maxLines = 9;
    final double maxHeight =
        fontSize * lineHeight * maxLines + 8; // + padding nhỏ

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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.event.title,
                          style: t.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: st(context, 18),
                            color: textColor,
                          ),
                          maxLines: null,
                        ),
                      ),
                      SizedBox(width: 12),
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

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
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
                      SizedBox(width: sw(context, 12)),
                      Expanded(
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

                      if (widget.event.status == 'Approved' ||
                          widget.event.status == 'Pending')
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: secondaryText),
                          position: PopupMenuPosition.under,
                          offset: const Offset(-16, 8),
                          onSelected: (value) {
                            if (value == 'cancel') {
                              showDialog(
                                context: context,
                                builder: (_) => HostCancelEventDialog(
                                  isHost: true,
                                  token: widget.token,
                                  eventId: widget.event.id,
                                  eventRepository: widget.eventRepository,
                                  parentContext: context,
                                  onCancelSuccess: widget.onCancel,
                                ),
                              );
                            }
                          },
                          itemBuilder: (_) => [
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
                                    loc.translate('cancel_event'),
                                    style: const TextStyle(
                                      color: Colors.redAccent,
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

                  Container(
                    constraints: BoxConstraints(maxHeight: maxHeight),
                    child: SingleChildScrollView(
                      child: RenderUtils.selectableMarkdownText(
                        context,
                        widget.event.description.isNotEmpty
                            ? widget.event.description
                            : loc.translate('no_description'),
                        style: TextStyle(
                          fontSize: fontSize,
                          height: lineHeight,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

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
                    "$currentParticipantCount/${widget.event.capacity}",
                    textColor,
                    secondaryText,
                    onTapValue: () async {
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
                            eventStatus: widget.event.status,
                            eventRepository: widget.eventRepository,
                            onKick: (kickedUserId, allowRejoin) {
                              setState(() {
                                if (allowRejoin) {
                                  currentParticipantCount--;
                                }
                              });
                            },
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                  ),

                  _buildInfoRow(
                    context,
                    Icons.access_time,
                    loc.translate('time'),
                    dateFormatted,
                    textColor,
                    secondaryText,
                  ),
                  _buildInfoRow(
                    context,
                    Icons.timer_outlined,
                    loc.translate('duration'),
                    durationFormatted,
                    textColor,
                    secondaryText,
                  ),
                  _buildInfoRow(
                    context,
                    Icons.monetization_on_outlined,
                    loc.translate('fee'),
                    widget.event.fee > 0
                        ? "${widget.event.fee}đ"
                        : loc.translate('free'),
                    textColor,
                    secondaryText,
                  ),

                  const SizedBox(height: 16),
                  Divider(color: dividerColor, thickness: 1),
                  const SizedBox(height: 16),

                  if (widget.event.status == 'Approved' ||
                      widget.event.status == 'Live' ||
                      widget.event.status == 'Completed')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Share button
                        if ((widget.event.isPublic ||
                                widget.event.status == 'Approved' ||
                                widget.event.status == 'Live') &&
                            widget.event.status != 'Completed')
                          AppButton(
                            variant: ButtonVariant.outline,
                            size: ButtonSize.sm,
                            icon: const Icon(Icons.share_outlined, size: 18),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) =>
                                    ShareEventDialog(targetId: widget.event.id),
                              );
                            },
                          ),

                        if (widget.event.status == 'Completed' ||
                            widget.event.status == 'Approved' ||
                            widget.event.status == 'Live')
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: AppButton(
                              size: ButtonSize.sm,
                              variant: ButtonVariant.outline,
                              icon: Icon(
                                Icons.bar_chart,
                                size: 18,
                                color:
                                    (!widget.event.hostPayoutClaimed &&
                                        widget.event.fee != 0)
                                    ? Colors.green
                                    : null,
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => StatisticEvent(
                                      eventId: widget.event.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        if (widget.event.status == 'Completed')
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: AppButton(
                                  variant: ButtonVariant.outline,
                                  size: ButtonSize.sm,
                                  icon: const Icon(
                                    Icons.star_outline,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => RatesScreen(
                                          eventId: widget.event.id,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: AppButton(
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
                                          eventId: widget.event.id,
                                          token: widget.token,
                                          isHost: true,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),

                        // Join/Start/Wait button cho Approved/Live
                        if (widget.event.status == 'Approved' ||
                            widget.event.status.toLowerCase() == 'live')
                          Builder(
                            builder: (_) {
                              final now = DateTime.now();
                              final isEventStarted = now.isAfter(
                                widget.event.startAt,
                              );
                              final isLive =
                                  widget.event.status.toLowerCase() == 'live';

                              final buttonText = isLive
                                  ? loc.translate('join')
                                  : isEventStarted
                                  ? loc.translate('start')
                                  : loc.translate('wait');

                              final canJoin = isLive || isEventStarted;

                              return Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: AppButton(
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
                                              'eventId': widget.event.id,
                                              'eventTitle': widget.event.title,
                                              'eventStatus': widget.event.status,
                                              'isHost': true,
                                              'hostId': widget.event.host.id,
                                              'hostName': widget.event.host.name,
                                              'startAt': widget.event.startAt,
                                              'sourceLanguage': widget.event.language.code,
                                            },
                                          );
                                        }
                                      : null,
                                  variant: canJoin
                                      ? ButtonVariant.primary
                                      : ButtonVariant.outline,
                                  color: canJoin
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey[300],
                                ),
                              );
                            },
                          ),
                      ],
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
