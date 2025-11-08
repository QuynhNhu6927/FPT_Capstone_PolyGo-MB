import 'package:flutter/material.dart';

import '../../../../data/services/signalr/webrtc_controller.dart';

class ChatPanel extends StatefulWidget {
  final List<ChatMessage> messages;
  final TextEditingController controller;
  final ValueChanged<String> onSend;
  final VoidCallback onClose;
  final String myName;

  const ChatPanel({
    super.key,
    required this.messages,
    required this.controller,
    required this.onSend,
    required this.onClose,
    required this.myName,
  });

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant ChatPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.45;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black87;
    final secondaryTextColor = theme.textTheme.bodySmall?.color ?? Colors.black45;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      bottom: 0,
      left: 0,
      right: 0,
      height: height,
      child: Material(
        elevation: 16,
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                color: cardColor,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Chat",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(icon: Icon(Icons.close, color: theme.iconTheme.color), onPressed: widget.onClose),
                ],
              ),
            ),

            const Divider(height: 1),

            // List tin nhắn
            Expanded(
              child: widget.messages.isEmpty
                  ? Center(
                child: Text(
                  "Chưa có tin nhắn nào",
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: widget.messages.length,
                itemBuilder: (context, index) {
                  final msg = widget.messages[index];
                  final isMe = msg.sender == widget.myName;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        // Tên người gửi
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            msg.sender,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ),

                        const SizedBox(height: 2),

                        // Hộp tin nhắn
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          margin: EdgeInsets.only(left: isMe ? 50 : 0, right: isMe ? 0 : 50),
                          decoration: BoxDecoration(
                            color: isMe ? theme.colorScheme.primary : theme.dividerColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            msg.message,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                          ),
                        ),

                        const SizedBox(height: 2),

                        // Thời gian
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}",
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: secondaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Input field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 3, offset: const Offset(0, -1)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: "Nhập tin nhắn...",
                        hintStyle: TextStyle(color: secondaryTextColor),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: theme.colorScheme.primary),
                    onPressed: () {
                      if (widget.controller.text.trim().isNotEmpty) {
                        widget.onSend(widget.controller.text.trim());
                        widget.controller.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
