import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../data/models/events/event_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/event_repository.dart';
import '../../../../data/services/apis/auth_service.dart';
import '../../../../data/services/apis/event_service.dart';
import '../../../../routes/app_routes.dart';

class EventDetail extends StatefulWidget {
  final EventModel event;
  final ValueChanged<EventModel>? onEventUpdated;
  const EventDetail({super.key, required this.event, this.onEventUpdated});

  @override
  State<EventDetail> createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  double _balance = 0;
  String _userPlanType = "Free";

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    try {
      final user = await AuthRepository(AuthService(ApiClient())).me(token);
      if (!mounted) return;
      setState(() {
        _balance = user.balance;
        _userPlanType = user.planType;
      });
    } catch (e) {
      //
    }
  }
  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    final dividerColor = isDark ? Colors.grey[700] : Colors.grey[300];
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final secondaryText = isDark ? Colors.grey[400] : Colors.grey[600];

    final isPastEvent = event.startAt.isBefore(DateTime.now());
    bool isDisabled = false;
    String buttonText = loc.translate('join');

    if (_userPlanType == "Free" && event.planType == "Plus") {
      isDisabled = true;
      buttonText = "Plus Only";
    } else if (event.isParticipant) {
      isDisabled = true;
      buttonText = loc.translate('joined');
    }

    final dateFormatted = DateFormat('dd MMM yyyy, hh:mm a').format(event.startAt);
    final durationFormatted =
        "${event.expectedDurationInMinutes ~/ 60}h ${event.expectedDurationInMinutes % 60}m";

    Future<bool?> _showPaidEventWarning() {
      return showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(loc.translate("paid_event_warning")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc.translate("paid_event_confirmation")),
              const SizedBox(height: 12),
              Text(
                "${loc.translate("available_balance")}: $_balanceđ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(loc.translate("cancel")),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(loc.translate("confirm")),
            ),
          ],
        ),
      );
    }

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (event.planType == "Plus") ...[
                          const SizedBox(width: 6),
                          Icon(Icons.star, size: 20, color: Colors.amber),
                        ],
                        Flexible(
                          child: Text(
                            event.title,
                            style: t.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: st(context, 18),
                              color: textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close,
                        size: 24, color: secondaryText ?? Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(color: dividerColor, thickness: 1),

              const SizedBox(height: 16),

              AspectRatio(
                aspectRatio: 16 / 9,
                child: event.bannerUrl.isNotEmpty
                    ? Image.network(
                  event.bannerUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.event_note_rounded,
                          size: 64, color: Colors.white70),
                    ),
                  ),
                )
                    : Container(
                  color: Colors.grey[400],
                  child: const Center(
                    child: Icon(Icons.event_note_rounded,
                        size: 64, color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.userProfile,
                        arguments: {'id': event.host.id},
                      );
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: sw(context, 28),
                          backgroundColor: Colors.grey[300],
                          backgroundImage: event.host.avatarUrl != null &&
                              event.host.avatarUrl!.isNotEmpty
                              ? NetworkImage(event.host.avatarUrl!)
                              : null,
                          child: (event.host.avatarUrl == null ||
                              event.host.avatarUrl!.isEmpty)
                              ? const Icon(Icons.person, size: 36, color: Colors.white70)
                              : null,
                        ),
                        SizedBox(width: sw(context, 12)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.host.name,
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
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text(
                event.description.isNotEmpty
                    ? event.description
                    : loc.translate('no_description'),
                style: t.bodyMedium?.copyWith(
                  fontSize: st(context, 14),
                  height: 1.4,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 16),

              _buildInfoRow(
                context,
                Icons.language,
                loc.translate('language'),
                event.language.name,
                textColor,
                secondaryText,
              ),
              _buildInfoRow(
                context,
                Icons.category_outlined,
                loc.translate('categories'),
                event.categories.isNotEmpty
                    ? event.categories.map((e) => e.name).join(', ')
                    : loc.translate('none'),
                textColor,
                secondaryText,
              ),
              _buildInfoRow(
                context,
                Icons.people_alt_outlined,
                loc.translate('participants'),
                "${event.numberOfParticipants}/${event.capacity}",
                textColor,
                secondaryText,
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
                event.fee > 0 ? "${event.fee}đ" : loc.translate('free'),
                textColor,
                secondaryText,
              ),

              const SizedBox(height: 16),
              Divider(color: dividerColor, thickness: 1),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    variant: ButtonVariant.outline,
                    size: ButtonSize.md,
                    icon: const Icon(Icons.share_outlined, size: 18),
                    onPressed: () {},
                  ),
                  if (!isPastEvent) ...[
                    SizedBox(width: sw(context, 12)),
                    AppButton(
                      text: buttonText,
                      variant: ButtonVariant.primary,
                      size: ButtonSize.md,
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      onPressed: isDisabled ? null : () async {

                        final prefs = await SharedPreferences.getInstance();
                        final token = prefs.getString('token') ?? '';
                        if (token.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(loc.translate("missing_token"))),
                          );
                          return;
                        }

                        Future<void> registerEvent(String password) async {
                          final repository = EventRepository(EventService(ApiClient()));
                          try {
                            await repository.registerEvent(
                              token: token,
                              eventId: event.id,
                              password: password,
                            );
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(loc.translate("event_register_success"))),
                            );
                            widget.onEventUpdated?.call(widget.event.copyWith(isParticipant: true));
                            Navigator.pop(context);
                          } catch (e) {
                            final errorString = e.toString();
                            if (errorString.contains("Error.InvalidEventPassword")) {
                              throw "wrong_password";
                            } else {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(errorString)),
                              );
                            }
                          }
                        }

                        if (event.fee > 0) {
                          final confirmPaid = await _showPaidEventWarning();
                          if (confirmPaid != true) return;
                        }

                        if (event.isPublic) {
                          await registerEvent('');
                          return;
                        }

                        final controller = TextEditingController();
                        await showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            String? errorText;
                            return StatefulBuilder(builder: (context, setState) {
                              return AlertDialog(
                                title: Text(loc.translate("enter_event_password")),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: controller,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        hintText: loc.translate("password"),
                                        border: const OutlineInputBorder(),
                                        errorText: errorText,
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(loc.translate("cancel")),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (controller.text.isEmpty) {
                                        setState(() {
                                          errorText = loc.translate("password_required");
                                        });
                                        return;
                                      }

                                      try {
                                        await EventRepository(EventService(ApiClient()))
                                            .registerEvent(
                                          token: token,
                                          eventId: event.id,
                                          password: controller.text,
                                        );

                                        if (!mounted) return;
                                        widget.onEventUpdated?.call(widget.event.copyWith(isParticipant: true));
                                        Navigator.of(context, rootNavigator: true).pop();
                                        Navigator.pop(context);

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(loc.translate("event_register_success"))),
                                        );

                                      } catch (e) {
                                        final err = e.toString();
                                        if (err.contains("Error.InvalidEventPassword")) {
                                          setState(() {
                                            errorText = loc.translate("wrong_password");
                                          });
                                        } else {
                                          if (!mounted) return;
                                          setState(() {
                                            errorText = loc.translate("wrong_password");
                                          });
                                        }
                                      }
                                    },
                                    child: Text(loc.translate("confirm")),
                                  ),
                                ],
                              );
                            });
                          },
                        );
                      },
                    ),
                  ],
                ],
              )

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
      Color? secondaryText,
      ) {
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
                      color: textColor,
                      fontSize: st(context, 14),
                    ),
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

extension EventModelCopy on EventModel {
  EventModel copyWith({bool? isParticipant}) {
    return EventModel(
      id: id,
      title: title,
      description: description,
      status: status,
      startAt: startAt,
      expectedDurationInMinutes: expectedDurationInMinutes,
      registerDeadline: registerDeadline,
      allowLateRegister: allowLateRegister,
      capacity: capacity,
      fee: fee,
      bannerUrl: bannerUrl,
      isPublic: isPublic,
      numberOfParticipants: numberOfParticipants,
      planType: planType,
      isParticipant: isParticipant ?? this.isParticipant,
      host: host,
      language: language,
      categories: categories,
    );
  }
}
