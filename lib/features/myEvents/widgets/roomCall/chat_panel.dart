import 'package:flutter/material.dart';

import '../../../../data/services/webrtc_controller.dart';

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

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      bottom: 0,
      left: 0,
      right: 0,
      height: height,
      child: Material(
        elevation: 16,
        color: const Color(0xFFF8F9FA),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Chat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                  IconButton(icon: const Icon(Icons.close, color: Colors.black54), onPressed: widget.onClose),
                ],
              ),
            ),

            const Divider(height: 1),

            // List tin nhắn
            Expanded(
              child: widget.messages.isEmpty
                  ? const Center(child: Text("Chưa có tin nhắn nào", style: TextStyle(color: Colors.grey)))
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
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            msg.sender,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),

                        const SizedBox(height: 2),

                        // Hộp tin nhắn
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          margin: EdgeInsets.only(left: isMe ? 50 : 0, right: isMe ? 0 : 50),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blueAccent : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            msg.message,
                            style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                          ),
                        ),

                        const SizedBox(height: 2),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black45,
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
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, -1))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      style: const TextStyle(color: Colors.black87),
                      decoration: const InputDecoration(
                        hintText: "Nhập tin nhắn...",
                        hintStyle: TextStyle(color: Colors.black45),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blueAccent),
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
