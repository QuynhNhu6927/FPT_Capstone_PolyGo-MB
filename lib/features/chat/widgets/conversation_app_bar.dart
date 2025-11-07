import 'package:flutter/material.dart';

class ConversationAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String avatarHeader;

  const ConversationAppBar({
    super.key,
    required this.userName,
    required this.avatarHeader,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? Colors.black : Colors.white;
    final shadowColor = isDark
        ? Colors.grey.withOpacity(0.1)
        : Colors.black.withOpacity(0.08);

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
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: (avatarHeader.isEmpty) ? Colors.grey : Colors.transparent,
              backgroundImage: (avatarHeader.isNotEmpty) ? NetworkImage(avatarHeader) : null,
              child: (avatarHeader.isEmpty)
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                userName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              print('Call pressed');
            },
            icon: Icon(Icons.call, color: isDark ? Colors.white : Colors.black),
          ),
          IconButton(
            onPressed: () {
              print('Video pressed');
            },
            icon: Icon(Icons.videocam, color: isDark ? Colors.white : Colors.black),
          ),
          IconButton(
            onPressed: () {
              print('Settings pressed');
            },
            icon: Icon(Icons.more_vert, color: isDark ? Colors.white : Colors.black),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
