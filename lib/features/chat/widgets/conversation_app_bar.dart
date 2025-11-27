import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/audioplayers.dart';
import '../../../data/services/signalr/user_presence.dart';
import '../screens/calling_screen.dart';
import 'conversation_setting.dart';

class ConversationAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String conversationId;
  final String userName;
  final String avatarHeader;
  final bool isOnline;
  final String lastActiveAt;
  final String receiverId;

  const ConversationAppBar({
    super.key,
    required this.conversationId,
    required this.receiverId,
    required this.userName,
    required this.avatarHeader,
    required this.isOnline,
    required this.lastActiveAt,
  });

  @override
  State<ConversationAppBar> createState() => _ConversationAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ConversationAppBarState extends State<ConversationAppBar> {
  String _formatLastActive(String? date) {
    if (date == null || date.isEmpty) return '';
    try {
      final dt = DateTime.parse(date).toLocal();
      return _timeAgo(dt);
    } catch (_) {
      return '';
    }
  }

  String _timeAgo(DateTime dateTime) {
    final loc = AppLocalizations.of(context);
    final diff = DateTime.now().difference(dateTime);

    if (diff.inSeconds < 60) return loc.translate("just_now");
    if (diff.inMinutes < 60) return '${diff.inMinutes} ${loc.translate("minutes_ago")}';
    if (diff.inHours < 24) return '${diff.inHours} ${loc.translate("hours_ago")}';
    if (diff.inDays < 7) return '${diff.inDays} ${loc.translate("days_ago")}';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} ${loc.translate("weeks_ago")}';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} ${loc.translate("months_ago")}';
    return '${(diff.inDays / 365).floor()} ${loc.translate("year_ago")}';
  }

  Future<bool> _requestCallPermissions(bool isVideoCall) async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) return false;

    if (isVideoCall) {
      final camStatus = await Permission.camera.request();
      if (!camStatus.isGranted) return false;
    }

    return true;
  }

  Future<void> _handleCall() async {
    final loc = AppLocalizations.of(context);
    try {
      final granted = await _requestCallPermissions(false);
      if (!granted) {
        CallSoundManager().stopRingTone();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('permission_denied'))),
        );
        return;
      }

      final statusMap = await UserPresenceManager().service.getOnlineStatus([widget.receiverId]);
      final isReceiverOnline = statusMap[widget.receiverId] ?? false;

      if (!isReceiverOnline) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('user_offline'))),
        );
        return;
      }

      if (!mounted) return;
      CallSoundManager().playRingTone();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CallingScreen(
            receiverId: widget.receiverId,
            receiverName: widget.userName,
            receiverAvatar: widget.avatarHeader,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('cannot_check_status'))),
      );
    }
  }

  // Trong _ConversationAppBarState
  Future<void> _handleVideoCall() async {
    final loc = AppLocalizations.of(context);
    try {
      final granted = await _requestCallPermissions(true);
      if (!granted) {
        CallSoundManager().stopRingTone();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('permission_denied'))),
        );
        return;
      }

      final statusMap = await UserPresenceManager().service.getOnlineStatus([widget.receiverId]);
      final isReceiverOnline = statusMap[widget.receiverId] ?? false;

      if (!isReceiverOnline) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('user_offline'))),
        );
        return;
      }

      if (!mounted) return;
      CallSoundManager().playRingTone();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CallingScreen(
            receiverId: widget.receiverId,
            receiverName: widget.userName,
            receiverAvatar: widget.avatarHeader,
            isVideoCall: true, // bật video call
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('cannot_check_status'))),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);
    final bgColor = isDark ? Colors.black : Colors.white;
    final shadowColor = isDark
        ? Colors.grey.withOpacity(0.1)
        : Colors.black.withOpacity(0.08);

    final formattedLastActive = widget.isOnline
        ? loc.translate('online')
        : (widget.lastActiveAt.isNotEmpty
        ? '${loc.translate('last_seen')}: ${_formatLastActive(widget.lastActiveAt)}'
        : '');

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: widget.avatarHeader.isEmpty ? Colors.grey : Colors.transparent,
                  backgroundImage:
                  widget.avatarHeader.isNotEmpty ? NetworkImage(widget.avatarHeader) : null,
                  child: widget.avatarHeader.isEmpty
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                if (widget.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: bgColor, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.userName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  if (formattedLastActive.isNotEmpty)
                    Text(
                      formattedLastActive,
                      style: TextStyle(
                        color: widget.isOnline
                            ? Colors.green
                            : (isDark ? Colors.grey[400] : Colors.grey[700]),
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _handleCall,
            icon: Icon(Icons.call, color: isDark ? Colors.white : Colors.black),
          ),
          IconButton(
            onPressed: _handleVideoCall,
            icon: Icon(Icons.videocam, color: isDark ? Colors.white : Colors.black),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ConversationSetting(
                    conversationId: widget.conversationId,
                  ),
                ),
              );
            },
            icon: Icon(Icons.more_vert, color: isDark ? Colors.white : Colors.black),
          ),
        ],
      ),
    );
  }
}
