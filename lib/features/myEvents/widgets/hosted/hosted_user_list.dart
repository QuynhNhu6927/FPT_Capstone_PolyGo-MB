import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../data/models/events/event_details_model.dart';
import '../../../../data/repositories/event_repository.dart';
import '../../../../routes/app_routes.dart';

class HostedUserList extends StatefulWidget {
  final List<ParticipantModel> participants;
  final String hostId;
  final String token;
  final String eventId;
  final String eventStatus;
  final EventRepository eventRepository;
  final VoidCallback? onClose;
  final void Function(String kickedUserId)? onKick;

  const HostedUserList({
    super.key,
    required this.participants,
    required this.hostId,
    required this.token,
    required this.eventId,
    required this.eventStatus,
    required this.eventRepository,
    this.onClose,
    this.onKick,
  });

  @override
  State<HostedUserList> createState() => _HostedUserListState();
}

class _HostedUserListState extends State<HostedUserList> {
  late List<ParticipantModel> participants;

  @override
  void initState() {
    super.initState();
    participants = [...widget.participants];
  }

  void _handleKick(String userId) {
    setState(() {
      participants.removeWhere((u) => u.id == userId);
    });
    widget.onKick?.call(userId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 600 ? 2 : width < 1000 ? 3 : 4;
    final loc = AppLocalizations.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.translate('participants_list'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onClose?.call();
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// List
            Expanded(
              child: MasonryGridView.count(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemCount: participants.length,
                itemBuilder: (context, index) {
                  final user = participants[index];
                  return _buildUserCard(context, user);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, ParticipantModel user) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasAvatar = (user.avatarUrl ?? '').isNotEmpty;
    final isLocked = user.status == 3;
    final loc = AppLocalizations.of(context);

    return GestureDetector(
      onTap: isLocked
          ? null
          : () {
        Navigator.pushNamed(
          context,
          AppRoutes.userProfile,
          arguments: {'id': user.id},
        );
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color:
                  isDark ? Colors.black.withOpacity(0.3) : Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Avatar
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: hasAvatar
                            ? Image.network(
                          user.avatarUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[400],
                            child: const Center(
                              child: Icon(
                                Icons.person,
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                            : Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.grey[400],
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  /// Name + Kick
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),

                        /// Kick button
                        if (widget.hostId != user.id &&
                            !isLocked &&
                            widget.eventStatus == "Approved")
                          GestureDetector(
                            onTap: () async {
                              final reasonController = TextEditingController();
                              bool allowRejoin = true;

                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  final theme = Theme.of(context);
                                  final isDark =
                                      theme.brightness == Brightness.dark;
                                  final textColor =
                                  isDark ? Colors.white : Colors.black;

                                  final Gradient cardBackground = isDark
                                      ? const LinearGradient(
                                    colors: [
                                      Color(0xFF1E1E1E),
                                      Color(0xFF2C2C2C)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                      : const LinearGradient(
                                    colors: [Colors.white, Colors.white],
                                  );

                                  return StatefulBuilder(
                                    builder: (context, setState) => Dialog(
                                      backgroundColor: Colors.transparent,
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          gradient: cardBackground,
                                          borderRadius:
                                          BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              loc.translate('kick_user'),
                                              style: theme
                                                  .textTheme.titleMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: textColor,
                                              ),
                                            ),
                                            const SizedBox(height: 16),

                                            /// Reason
                                            TextField(
                                              controller: reasonController,
                                              decoration: InputDecoration(
                                                labelText:
                                                loc.translate('reason'),
                                                border:
                                                const OutlineInputBorder(),
                                              ),
                                            ),

                                            const SizedBox(height: 16),

                                            /// Allow Rejoin Switch
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    loc.translate(
                                                        'allow_rejoin'),
                                                    style: TextStyle(
                                                        color: textColor),
                                                  ),
                                                ),
                                                Switch(
                                                  value: allowRejoin,
                                                  onChanged: (v) => setState(
                                                          () => allowRejoin = v),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 16),

                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.end,
                                              children: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(false),
                                                  child: Text(
                                                      loc.translate('cancel')),
                                                ),
                                                const SizedBox(width: 8),
                                                AppButton(
                                                  text: loc.translate('kick'),
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(true),
                                                  size: ButtonSize.sm,
                                                  variant:
                                                  ButtonVariant.primary,
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

                              if (confirmed == true) {
                                try {
                                  await widget.eventRepository.kickUser(
                                    token: widget.token,
                                    eventId: widget.eventId,
                                    userId: user.id,
                                    allowRejoin: allowRejoin,
                                    reason: reasonController.text.isNotEmpty
                                        ? reasonController.text
                                        : loc.translate('against_rule'),
                                  );

                                  if (!mounted) return;
                                  _handleKick(user.id);
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.maybeOf(context)
                                      ?.showSnackBar(
                                    SnackBar(
                                      content:
                                      Text(loc.translate('kick_failed')),
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Icon(
                              Icons.remove_circle_outline_sharp,
                              size: 18,
                              color: Colors.red,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms),
    );
  }
}
