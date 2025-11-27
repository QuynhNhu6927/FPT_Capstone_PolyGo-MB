import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/date_separator.dart';
import '../../../data/models/chat/conversation_message_model.dart';
import 'chat_bubble.dart';

class MessageItem extends StatelessWidget {
  final ConversationMessage message;
  final bool isMine;
  final bool isDark;
  final Color colorPrimary;
  final String? activeMessageId;
  final VoidCallback onTap;
  final bool showDateSeparator;
  final Function(String messageId)? onDelete;
  final Future<void> Function()? onTranslate;

  const MessageItem({
    super.key,
    required this.message,
    required this.isMine,
    required this.isDark,
    required this.colorPrimary,
    this.activeMessageId,
    required this.onTap,
    required this.showDateSeparator,
    this.onDelete,
    this.onTranslate,
  });

  @override
  Widget build(BuildContext context) {
    final currentDate = DateTime.tryParse(message.sentAt)?.toLocal();
    final loc = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showDateSeparator && currentDate != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Expanded(child: Divider(thickness: 1, color: Colors.grey)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    formatDateSeparator(context, currentDate),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                ),
                const Expanded(child: Divider(thickness: 1, color: Colors.grey)),
              ],
            ),
          ),
        // Tin nhắn
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMine)
                CircleAvatar(
                  radius: 18,
                  backgroundColor: (message.sender.avatarUrl == null ||
                      message.sender.avatarUrl!.isEmpty)
                      ? Colors.grey
                      : Colors.transparent,
                  backgroundImage: (message.sender.avatarUrl != null &&
                      message.sender.avatarUrl!.isNotEmpty)
                      ? NetworkImage(message.sender.avatarUrl!)
                      : null,
                  child: (message.sender.avatarUrl == null ||
                      message.sender.avatarUrl!.isEmpty)
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
              if (!isMine) const SizedBox(width: 8),
              Flexible(
                child: GestureDetector(
                  onTap: onTap,
                  onLongPress: () {
                    if (isMine && onDelete != null) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(loc.translate("erase_mess")),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(loc.translate("cancel")),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                onDelete!(message.id);
                              },
                              child: Text(loc.translate("confirm"), style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: ChatBubble(
                    message: message,
                    isMine: isMine,
                    isDark: isDark,
                    colorPrimary: colorPrimary,
                    activeMessageId: activeMessageId,
                    onTap: onTap,
                    onTranslate: onTranslate,
                  ),
                ),
              ),

              if (isMine) const SizedBox(width: 8),
              if (isMine)
                CircleAvatar(
                  radius: 18,
                  backgroundColor: (message.sender.avatarUrl == null ||
                      message.sender.avatarUrl!.isEmpty)
                      ? Colors.grey
                      : Colors.transparent,
                  backgroundImage: (message.sender.avatarUrl != null &&
                      message.sender.avatarUrl!.isNotEmpty)
                      ? NetworkImage(message.sender.avatarUrl!)
                      : null,
                  child: (message.sender.avatarUrl == null ||
                      message.sender.avatarUrl!.isEmpty)
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
            ],
          ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.1, end: 0),
        ),
      ],
    );
  }
}
