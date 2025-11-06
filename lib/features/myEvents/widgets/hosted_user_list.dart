import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../data/models/events/event_details_model.dart';
import '../../../data/repositories/event_repository.dart';
import '../../../routes/app_routes.dart';

class HostedUserList extends StatefulWidget {
  final List<ParticipantModel> participants;
  final String hostId;
  final String token;
  final String eventId;
  final EventRepository eventRepository;
  final VoidCallback? onClose;
  final void Function(String kickedUserId)? onKick;

  const HostedUserList({
    super.key,
    required this.participants,
    required this.hostId,
    required this.token,
    required this.eventId,
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
      final index = participants.indexWhere((u) => u.id == userId);
      if (index != -1) {
        participants[index] = participants[index].copyWith(status: 3);
      }
    });
    widget.onKick?.call(userId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 600 ? 2 : width < 1000 ? 3 : 4;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Danh sách người tham dự",
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
    final hasAvatar = user.avatarUrl.isNotEmpty;
    final isLocked = user.status == 3;

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
                  color: isDark ? Colors.black.withOpacity(0.3) : Colors.black12,
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
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: hasAvatar
                            ? Image.network(
                          user.avatarUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.person,
                                size: 80, color: Colors.white70),
                          ),
                        )
                            : Container(
                          color: Colors.grey[400],
                          child: const Center(
                            child: Icon(Icons.person,
                                size: 80, color: Colors.white70),
                          ),
                        ),
                      ),
                      if (widget.hostId != user.id && !isLocked)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () async {
                              final reasonController = TextEditingController();

                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Xác nhận kick'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Bạn có chắc muốn kick ${user.name}?'),
                                      const SizedBox(height: 12),
                                      TextField(
                                        controller: reasonController,
                                        decoration: const InputDecoration(
                                          labelText: 'Lý do',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Hủy'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Kick'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true) {
                                try {
                                  await widget.eventRepository.kickUser(
                                    token: widget.token,
                                    eventId: widget.eventId,
                                    userId: user.id,
                                    reason: reasonController.text.isNotEmpty
                                        ? reasonController.text
                                        : 'Vi phạm quy định',
                                  );
                                  _handleKick(user.id);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Kick thất bại: $e')),
                                  );
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              child:
                              const Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                ],
              ),
            ),
          ),
          if (isLocked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(Icons.lock, color: Colors.white, size: 40),
                ),
              ),
            ),
        ],
      ).animate().fadeIn(duration: 300.ms),
    );
  }
}
