import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../data/services/signalr/user_presence.dart';
import '../screens/calling_screen.dart';

class ConversationAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String userName;
  final String avatarHeader;
  final bool isOnline;
  final String lastActiveAt;
  final String receiverId;

  const ConversationAppBar({
    super.key,
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
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (_) {
      return '';
    }
  }

  Future<void> _handleCall() async {
    try {
      final statusMap = await UserPresenceManager().service.getOnlineStatus([widget.receiverId]);
      final isReceiverOnline = statusMap[widget.receiverId] ?? false;

      if (!isReceiverOnline) {
        if (!mounted) return; // check mounted trước khi dùng context
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Người dùng hiện đang offline")),
        );
        return;
      }

      if (!mounted) return;
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
      debugPrint("❌ Error checking user online status: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không thể kiểm tra trạng thái người dùng")),
      );
    }
  }

  // Trong _ConversationAppBarState
  Future<void> _handleVideoCall() async {
    try {
      final statusMap = await UserPresenceManager().service.getOnlineStatus([widget.receiverId]);
      final isReceiverOnline = statusMap[widget.receiverId] ?? false;

      if (!isReceiverOnline) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Người dùng hiện đang offline")),
        );
        return;
      }

      if (!mounted) return;
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
      debugPrint("❌ Error checking user online status: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không thể kiểm tra trạng thái người dùng")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? Colors.black : Colors.white;
    final shadowColor = isDark
        ? Colors.grey.withOpacity(0.1)
        : Colors.black.withOpacity(0.08);

    final formattedLastActive = widget.isOnline
        ? 'Đang hoạt động'
        : (widget.lastActiveAt.isNotEmpty
        ? 'Lần cuối: ${_formatLastActive(widget.lastActiveAt)}'
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
              debugPrint('Settings pressed');
            },
            icon: Icon(Icons.more_vert, color: isDark ? Colors.white : Colors.black),
          ),
        ],
      ),
    );
  }
}
