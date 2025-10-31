import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/responsive.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/models/events/event_details_model.dart';
import '../../../data/models/events/hosted_event_model.dart';
import '../../../data/repositories/event_repository.dart';
import 'hosted_user_list.dart';

class HostedEventDetails extends StatefulWidget {
  final HostedEventModel event;
  final EventRepository eventRepository;
  final String token;
  final VoidCallback? onCancel;
  final BuildContext parentContext;

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

  @override
  Widget build(BuildContext context) {
    late List<ParticipantModel> participants;
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    final dividerColor = isDark ? Colors.grey[700] : Colors.grey[300];
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final secondaryText = isDark ? Colors.grey[400] : Colors.grey[600];

    final dateFormatted = DateFormat('dd MMM yyyy, hh:mm a').format(widget.event.startAt);
    final durationFormatted =
        "${widget.event.expectedDurationInMinutes ~/ 60}h ${widget.event.expectedDurationInMinutes % 60}m";

    return Dialog(
      elevation: 12,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(sw(context, 16))),
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
                    child: Icon(Icons.close, size: 24, color: secondaryText ?? Colors.grey),
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
                      child: Icon(Icons.event_note_rounded, size: 64, color: Colors.white70),
                    ),
                  ),
                )
                    : Container(
                  color: Colors.grey[400],
                  child: const Center(
                    child: Icon(Icons.event_note_rounded, size: 64, color: Colors.white70),
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
                    backgroundImage: (widget.event.host.avatarUrl != null &&
                        widget.event.host.avatarUrl!.isNotEmpty)
                        ? NetworkImage(widget.event.host.avatarUrl!)
                        : null,
                    child: (widget.event.host.avatarUrl == null ||
                        widget.event.host.avatarUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 36, color: Colors.white70)
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
                              color: secondaryText, fontSize: st(context, 13)),
                        ),
                      ],
                    ),
                  ),

                  if (widget.event.status != 'Cancelled')
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
                              return StatefulBuilder(builder: (context, setState) {
                                return AlertDialog(
                                  title: Text(loc.translate('confirm_cancel')),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(loc.translate('enter_cancel_reason')),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: reasonController,
                                        maxLines: 3,
                                        decoration: InputDecoration(
                                          hintText: loc.translate('cancel_reason_placeholder'),
                                          border: const OutlineInputBorder(),
                                          contentPadding:
                                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          errorText: errorText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(dialogContext),
                                      child: Text(loc.translate('no')),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        final reason = reasonController.text.trim();
                                        if (reason.isEmpty) {
                                          setState(() {
                                            errorText = loc.translate('enter_reason_first');
                                          });
                                          return;
                                        }

                                        try {
                                          final res = await widget.eventRepository.cancelEvent(
                                            token: widget.token,
                                            eventId: widget.event.id,
                                            reason: reason,
                                          );

                                          if (!mounted) return;

                                          Navigator.of(context, rootNavigator: true).pop();
                                          Navigator.pop(context);

                                          widget.onCancel?.call();

                                          ScaffoldMessenger.of(widget.parentContext).showSnackBar(
                                            SnackBar(
                                              content: Text(res?.message ??
                                                  loc.translate('cancel_success')),
                                            ),
                                          );
                                        } catch (_) {
                                          ScaffoldMessenger.of(widget.parentContext).showSnackBar(
                                            SnackBar(
                                              content: Text(loc.translate('error_occurred')),
                                            ),
                                          );
                                        }
                                      },
                                      child: Text(loc.translate('yes')),
                                    ),
                                  ],
                                );
                              });
                            },
                          );
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'cancel',
                          child: Row(
                            children: [
                              const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                loc.translate('cancel'),
                                style: const TextStyle(
                                    color: Colors.redAccent, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 20),

              Text(
                widget.event.description.isNotEmpty
                    ? widget.event.description
                    : loc.translate('no_description'),
                style: t.bodyMedium?.copyWith(
                    fontSize: st(context, 14),
                    height: 1.4,
                    color: textColor),
              ),
              const SizedBox(height: 16),

              _buildInfoRow(context, Icons.language, loc.translate('language'),
                  widget.event.language.name, textColor, secondaryText),
              _buildInfoRow(
                  context,
                  Icons.category_outlined,
                  loc.translate('categories'),
                  widget.event.categories.isNotEmpty
                      ? widget.event.categories.map((e) => e.name).join(', ')
                      : loc.translate('none'),
                  textColor,
                  secondaryText),
              _buildInfoRow(
                context,
                Icons.people_alt_outlined,
                loc.translate('participants'),
                "${widget.event.numberOfParticipants}/${widget.event.capacity}",
                textColor,
                secondaryText,
                onTapValue: () async {
                  try {
                    final eventDetails = await widget.eventRepository.getEventDetails(
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
                      SnackBar(content: Text(loc.translate('error_occurred'))),
                    );
                  }
                },
              ),

              _buildInfoRow(context, Icons.access_time, loc.translate('time'),
                  dateFormatted, textColor, secondaryText),
              _buildInfoRow(context, Icons.timer_outlined,
                  loc.translate('duration'), durationFormatted, textColor, secondaryText),
              _buildInfoRow(
                  context,
                  Icons.monetization_on_outlined,
                  loc.translate('fee'),
                  widget.event.fee > 0
                      ? "${widget.event.fee}đ"
                      : loc.translate('free'),
                  textColor,
                  secondaryText),

              const SizedBox(height: 16),
              Divider(color: dividerColor, thickness: 1),
              const SizedBox(height: 16),

              if (widget.event.status != 'Cancelled')
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton(
                      text: loc.translate('share'),
                      variant: ButtonVariant.outline,
                      size: ButtonSize.md,
                      icon: const Icon(Icons.share_outlined, size: 18),
                      onPressed: () {
                        //share
                      },
                    ),
                    const SizedBox(width: 12),
                    AppButton(
                      text: loc.translate('start'),
                      size: ButtonSize.md,
                      icon: const Icon(Icons.play_circle_outline, size: 18),
                      onPressed: () {
                        //start event
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
        .slide(begin: const Offset(0, 0.08), duration: 300.ms, curve: Curves.easeOutCubic);
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
