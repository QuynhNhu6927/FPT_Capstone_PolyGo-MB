import 'package:flutter/material.dart';
import '../widgets/conversation.dart';

class ConversationScreen extends StatefulWidget {
  final String conversationId;
  final String userName;

  const ConversationScreen({
    super.key,
    required this.conversationId,
    required this.userName,
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
      appBar: AppBar(
        title: Text(widget.userName),
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Conversation(
          conversationId: widget.conversationId,
          userName: widget.userName,
        ),
      ),
    );
  }
}
