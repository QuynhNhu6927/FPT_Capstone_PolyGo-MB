import 'package:flutter/material.dart';
import '../widgets/conversation.dart';

class ConversationScreen extends StatefulWidget {
  final String conversationId;
  final String userName;
  final String avatarHeader;
  final String lastActiveAt;
  final bool isOnline;

  const ConversationScreen({
    super.key,
    required this.conversationId,
    required this.lastActiveAt,
    required this.userName,
    required this.avatarHeader,
    required this.isOnline,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Conversation(
          conversationId: widget.conversationId,
          userName: widget.userName,
          lastActiveAt: widget.lastActiveAt,
          avatarHeader: widget.avatarHeader,
          isOnline: widget.isOnline,
        ),
      ),
    );
  }
}
