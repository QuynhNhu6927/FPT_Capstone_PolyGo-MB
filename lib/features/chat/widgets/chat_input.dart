import 'package:flutter/material.dart';

class ChatInputBar extends StatelessWidget {
  final bool isUploadingImages;
  final bool isDark;
  final Color colorPrimary;
  final TextEditingController controller;
  final ScrollController scrollController;
  final VoidCallback onPickImages;
  final Future<void> Function(String text) onSendText;

  const ChatInputBar({
    super.key,
    required this.isUploadingImages,
    required this.isDark,
    required this.colorPrimary,
    required this.controller,
    required this.scrollController,
    required this.onPickImages,
    required this.onSendText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: isUploadingImages ? null : onPickImages,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !isUploadingImages,
              decoration: InputDecoration(
                hintText: "Nhập tin nhắn...",
                filled: true,
                fillColor:
                isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF3F3F3),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 22,
            backgroundColor: colorPrimary,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: isUploadingImages
                  ? null
                  : () async {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                await onSendText(text);
                controller.clear();
                scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
