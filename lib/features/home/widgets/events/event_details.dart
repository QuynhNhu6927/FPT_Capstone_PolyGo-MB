import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/utils/render_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../data/models/events/event_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/event_repository.dart';
import '../../../../data/services/apis/auth_service.dart';
import '../../../../data/services/apis/event_service.dart';
import '../../../../routes/app_routes.dart';
import '../../../myEvents/widgets/joined/report_event_dialog.dart';
import '../../../shared/share_event_dialog.dart';

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
  String _userId = '';

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
        _userId = user.id;
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

    final now = DateTime.now();
    final isPastRegisterDeadline = event.registerDeadline.isBefore(now);

    final shouldHideJoinButton =
        isPastRegisterDeadline && (event.allowLateRegister == false);

    bool isDisabled = false;
    String buttonText = loc.translate('join');

    if (_userPlanType == "Free" && event.planType == "Plus") {
      isDisabled = true;
      buttonText = loc.translate("for_plus_only");
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
        barrierDismissible: true,
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final loc = AppLocalizations.of(context);

          return StatefulBuilder(
            builder: (context, setState) => Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(
                    colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                      : const LinearGradient(
                    colors: [Colors.white, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---- TITLE ----
                    Center(
                      child: Text(
                        loc.translate("paid_event_warning"),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ---- DIVIDER ----
                    Divider(
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                      thickness: 1,
                    ),

                    const SizedBox(height: 12),

                    // ---- DESCRIPTION ----
                    Text(
                      loc.translate("paid_event_confirmation"),
                      style: TextStyle(
                        color: isDark ? Colors.grey[300] : Colors.grey[800],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ---- AVAILABLE BALANCE ----
                    Text(
                      loc.translate("available_balance"),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // ---- SỐ DƯ (màu xám) ----
                    Text(
                      formatCurrency(_balance),
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ---- BUTTONS ----
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(loc.translate("cancel")),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(loc.translate("confirm")),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  /// LEFT — Avatar + host info
                  GestureDetector(
                    onTap: _userId != event.host.id
                        ? () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.userProfile,
                        arguments: {'id': event.host.id},
                      );
                    }
                        : null,
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

                  /// RIGHT — Report icon (only when user != host)
                  if (_userId.isNotEmpty && _userId != event.host.id)
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => ReportEventDialog(
                            eventId: event.id,
                            onSubmit: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        );
                      },
                      child: Icon(
                        Icons.flag_outlined,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),

                ],
              ),

              const SizedBox(height: 20),

              Container(
                constraints: BoxConstraints(
                  maxHeight: st(context, 14) * 1.4 * 4 + 8,
                ),
                child: SingleChildScrollView(
                  child: RenderUtils.selectableMarkdownText(
                    context,
                    event.description.isNotEmpty
                        ? event.description
                        : loc.translate('no_description'),
                    style: TextStyle(
                      fontSize: st(context, 14),
                      height: 1.4,
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
                Icons.event_available_outlined,
                loc.translate('register_deadline'),
                DateFormat('dd MMM yyyy, HH:mm').format(event.registerDeadline),
                textColor,
                secondaryText,
              ),

              _buildInfoRow(
                context,
                Icons.lock_clock_outlined,
                loc.translate('allow_late_register'),
                event.allowLateRegister ? loc.translate('yes') : loc.translate('no'),
                textColor,
                secondaryText,
              ),
              _buildInfoRow(
                context,
                Icons.monetization_on_outlined,
                loc.translate('fee'),
                event.fee > 0 ? formatCurrency(event.fee) : loc.translate('free'),
                textColor,
                secondaryText,
              ),

              const SizedBox(height: 16),
              Divider(color: dividerColor, thickness: 1),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (event.isPublic)
                  AppButton(
                    variant: ButtonVariant.outline,
                    size: ButtonSize.md,
                    icon: const Icon(Icons.share_outlined, size: 18),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => ShareEventDialog(
                          targetId: event.id,
                        ),
                      );
                    },
                  ),
                  if (!shouldHideJoinButton) ...[
                    SizedBox(width: sw(context, 12)),
                    AppButton(
                      text: buttonText,
                      variant: event.isParticipant
                          ? ButtonVariant.outline
                          : ButtonVariant.primary,
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

                        Future<void> registerEvent(String password,
                            {bool closeTwoDialogs = false}) async {
                          final repository = EventRepository(EventService(ApiClient()));
                          try {
                            await repository.registerEvent(
                              token: token,
                              eventId: event.id,
                              password: password,
                            );

                            if (!mounted) return;
                            widget.onEventUpdated
                                ?.call(widget.event.copyWith(isParticipant: true));

                            //  Đóng dialog
                            if (closeTwoDialogs) {
                              Navigator.of(context, rootNavigator: true).pop(); // password dialog
                              Navigator.pop(context); // event detail dialog
                            } else {
                              Navigator.pop(context); // chỉ event detail dialog
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                  Text(loc.translate("event_register_success"))),
                            );
                          } on InvalidEventPasswordException {
                            throw loc.translate("wrong_password");
                          } on KickedFromEventException {
                            if (!mounted) return;
                            if (closeTwoDialogs) {
                              Navigator.of(context, rootNavigator: true).pop();
                              Navigator.pop(context);
                            } else {
                              Navigator.pop(context);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(loc.translate("event_register_kicked"))),
                            );
                          } on EventsOverlappingException {
                            if (!mounted) return;
                            if (closeTwoDialogs) {
                              Navigator.of(context, rootNavigator: true).pop();
                              Navigator.pop(context);
                            } else {
                              Navigator.pop(context);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(loc.translate("event_overlapping"))),
                            );
                          } on InsufficientBalanceException {
                            if (!mounted) return;
                            if (closeTwoDialogs) {
                              Navigator.of(context, rootNavigator: true).pop();
                              Navigator.pop(context);
                            } else {
                              Navigator.pop(context);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(loc.translate("insufficient_balance"))),
                            );
                          } catch (_) {
                            if (!mounted) return;
                            if (closeTwoDialogs) {
                              Navigator.of(context, rootNavigator: true).pop();
                              Navigator.pop(context);
                            } else {
                              Navigator.pop(context);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(loc.translate("event_join_system_error"))),
                            );
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
                            final isDark =
                                Theme.of(context).brightness == Brightness.dark;
                            final loc = AppLocalizations.of(context);

                            return StatefulBuilder(builder: (context, setState) {
                              return Dialog(
                                backgroundColor: Colors.transparent,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: isDark
                                        ? const LinearGradient(
                                      colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                        : const LinearGradient(
                                      colors: [Colors.white, Colors.white],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // ---- TITLE ----
                                      Center(
                                        child: Text(
                                          loc.translate("enter_event_password"),
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: isDark ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      // ---- DIVIDER ----
                                      Divider(
                                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                                        thickness: 1,
                                      ),

                                      const SizedBox(height: 12),

                                      // ---- DESCRIPTION ----
                                      Text(
                                        loc.translate("private_event_description"), // hãy đặt key này trong localization
                                        style: TextStyle(
                                          color: isDark ? Colors.grey[300] : Colors.grey[800],
                                          fontSize: 14,
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      // ---- PASSWORD FIELD ----
                                      TextField(
                                        controller: controller,
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          hintText: loc.translate("password"),
                                          hintStyle: TextStyle(
                                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          errorText: errorText,
                                          contentPadding:
                                          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        ),
                                      ),

                                      const SizedBox(height: 16),

                                      // ---- BUTTONS ----
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: Text(loc.translate("cancel")),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF2563EB),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            onPressed: () async {
                                              if (controller.text.isEmpty) {
                                                setState(() {
                                                  errorText = loc.translate("password_required");
                                                });
                                                return;
                                              }

                                              try {
                                                await registerEvent(
                                                  controller.text,
                                                  closeTwoDialogs: true,
                                                );
                                              } catch (e) {
                                                if (e == "wrong_password") {
                                                  setState(() {
                                                    errorText = loc.translate("wrong_password");
                                                  });
                                                }
                                              }
                                            },
                                            child: Text(loc.translate("confirm")),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
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

String formatCurrency(num amount) {
  bool hasDecimal = (amount % 1) != 0;

  final formatter = NumberFormat.currency(
    locale: "vi_VN",
    decimalDigits: hasDecimal ? 2 : 0,
    symbol: "đ",
  );

  return formatter.format(amount).replaceAll(" ", " ");
}

