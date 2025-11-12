import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../routes/app_routes.dart';

class ConversationAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String avatarHeader;
  final bool isOnline;
  final String lastActiveAt;

  const ConversationAppBar({
    super.key,
    required this.userName,
    required this.avatarHeader,
    required this.isOnline,
    required this.lastActiveAt,
  });

  String _formatLastActive(String? date) {
    if (date == null || date.isEmpty) return '';
    try {
      final dt = DateTime.parse(date).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (_) {
      return '';
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

    final formattedLastActive = isOnline
        ? 'Đang hoạt động'
        : (lastActiveAt != null && lastActiveAt!.isNotEmpty
        ? 'Lần cuối: ${_formatLastActive(lastActiveAt)}'
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
                  backgroundColor:
                  (avatarHeader.isEmpty) ? Colors.grey : Colors.transparent,
                  backgroundImage:
                  (avatarHeader.isNotEmpty) ? NetworkImage(avatarHeader) : null,
                  child: (avatarHeader.isEmpty)
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: bgColor,
                          width: 2,
                        ),
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
                    userName,
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
                        color: isOnline
                            ? Colors.green
                            : (isDark
                            ? Colors.grey[400]
                            : Colors.grey[700]),
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
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppRoutes.call);
            },
            icon: Icon(Icons.call, color: isDark ? Colors.white : Colors.black),
          ),

          IconButton(
            onPressed: () {
              print('Settings pressed');
            },
            icon: Icon(Icons.more_vert,
                color: isDark ? Colors.white : Colors.black),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
