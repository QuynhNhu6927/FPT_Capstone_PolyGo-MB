import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:polygo_mobile/features/myEvents/widgets/joined/report_event_dialog.dart';

import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../data/models/events/joined_event_model.dart';
import '../../../../data/repositories/event_repository.dart';
import '../hosted/hosted_user_list.dart';
import 'action_buttons.dart';
import 'banner_section.dart';
import 'cancel_event_dialog.dart';
import 'description_section.dart';
import 'header_section.dart';
import 'host_section.dart';
import 'info_row.dart';

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
      setState(() => hasRating = myRating?.hasRating ?? false);
    } catch (_) {
      setState(() => hasRating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dividerColor = isDark ? Colors.grey[700] : Colors.grey[300];

    final eventLocal = widget.event.startAt.toLocal();
    final dateFormatted = DateFormat('dd MMM yyyy, HH:mm').format(eventLocal);

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
                  HeaderSection(
                    event: widget.event,
                    currentUserId: widget.currentUserId,
                    eventRepository: widget.eventRepository,
                    token: widget.token,
                    parentContext: widget.parentContext,
                    onCancel: widget.onCancel,
                    onEventCanceled: widget.onEventCanceled,
                  ),
                  const SizedBox(height: 16),

                  BannerSection(event: widget.event),
                  const SizedBox(height: 16),

                  HostSection(
                    event: widget.event,
                    trailing:
                        (widget.event.status != "Completed" &&
                                widget.event.status != "Cancelled" &&
                                widget.event.status != "Live") ||
                            (widget.currentUserId != widget.event.host.id)
                        ? PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_vert,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                            position: PopupMenuPosition.under,
                            offset: const Offset(-16, 8),
                            onSelected: (value) async {
                              final loc = AppLocalizations.of(context);
                              if (value == 'cancel') {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => CancelEventDialog(
                                    isHost:
                                        widget.currentUserId ==
                                        widget.event.host.id,
                                    token: widget.token,
                                    eventId: widget.event.id,
                                    parentContext: context,
                                    eventRepository: widget.eventRepository,
                                    onCancelSuccess: () {
                                      widget.onCancel?.call();
                                      widget.onEventCanceled?.call();
                                    },
                                  ),
                                );
                              } else if (value == 'report') {
                                showDialog(
                                  context: context,
                                  builder: (_) => ReportEventDialog(
                                    eventId: widget.event.id,
                                    onSubmit: () {
                                      Navigator.of(context).pop();
                                      widget.onCancel?.call();
                                    },
                                  ),
                                );
                              }

                            },
                            itemBuilder: (ctx) {
                              final List<PopupMenuEntry<String>> items = [];

                              // Report luôn hiển thị nếu currentUser khác host
                              if (widget.currentUserId !=
                                  widget.event.host.id) {
                                items.add(
                                  PopupMenuItem(
                                    value: 'report',
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.report_outlined,
                                          color: Colors.orange,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          AppLocalizations.of(
                                            context,
                                          ).translate('report'),
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              // Cancel/Unregister chỉ hiển thị khi event chưa Completed/Cancelled/Live
                              if (widget.event.status != "Completed" &&
                                  widget.event.status != "Cancelled" &&
                                  widget.event.status != "Live") {
                                items.add(
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
                                          AppLocalizations.of(
                                            context,
                                          ).translate('unregister_cancel'),
                                          style: const TextStyle(
                                            color: Colors.redAccent,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              return items;
                            },
                          )
                        : null,
                  ),

                  const SizedBox(height: 20),

                  DescriptionSection(event: widget.event),
                  const SizedBox(height: 16),

                  InfoRow(
                    icon: Icons.language,
                    label: loc.translate('language'),
                    value: widget.event.language.name,
                  ),
                  InfoRow(
                    icon: Icons.category_outlined,
                    label: loc.translate('categories'),
                    value: widget.event.categories.isNotEmpty
                        ? widget.event.categories.map((e) => e.name).join(', ')
                        : loc.translate('none'),
                  ),
                  InfoRow(
                    icon: Icons.people_alt_outlined,
                    label: loc.translate('participants'),
                    value:
                        "${widget.event.numberOfParticipants}/${widget.event.capacity}",
                    isClickable: widget.currentUserId == widget.event.host.id,
                    onTap: () async {
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
                            eventStatus: widget.event.status,
                            token: widget.token,
                            eventId: widget.event.id,
                            eventRepository: widget.eventRepository,
                          ),
                        );
                      } catch (_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(loc.translate('error_occurred')),
                          ),
                        );
                      }
                    },
                  ),
                  InfoRow(
                    icon: Icons.access_time,
                    label: loc.translate('time'),
                    value: dateFormatted,
                  ),
                  InfoRow(
                    icon: Icons.attach_money,
                    label: loc.translate('fee'),
                    value: formatFee(widget.event.fee),
                  ),

                  const SizedBox(height: 16),
                  Divider(color: dividerColor, thickness: 1),
                  const SizedBox(height: 16),

                  ActionButtons(
                    event: widget.event,
                    currentUserId: widget.currentUserId,
                    hasRating: hasRating,
                    token: widget.token,
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
}

String formatFee(int fee) {
  if (fee == 0) return 'Free';

  // tạo NumberFormat kiểu VNĐ
  final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
  String formatted = formatter.format(fee);
  return formatted;
}
