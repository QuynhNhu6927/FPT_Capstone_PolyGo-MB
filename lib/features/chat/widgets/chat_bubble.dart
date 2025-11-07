import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/chat/conversation_message_model.dart';

String formatTime(String sentAt) {
  if (sentAt.isEmpty) return '';
  final date = DateTime.tryParse(sentAt)?.toLocal();
  if (date == null) return '';
  return DateFormat('HH:mm').format(date);
}

class ChatBubble extends StatelessWidget {
  final ConversationMessage message;
  final bool isMine;
  final bool isDark;
  final Color colorPrimary;
  final String? activeMessageId;
  final VoidCallback onTap;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.isDark,
    required this.colorPrimary,
    this.activeMessageId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final showTime = activeMessageId == message.id;

    return Column(
      crossAxisAlignment:
      isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (showTime)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              formatTime(message.sentAt),
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
        GestureDetector(
          onTap: onTap,
          child: _buildContent(context),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    // Text message
    if (message.type == "Text") {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: isMine
              ? colorPrimary.withOpacity(0.85)
              : (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFDFDFDF)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: isMine ? Colors.white : (isDark ? Colors.white : Colors.black),
            fontSize: 14,
          ),
        ),
      );
    }

    // Image(s) message
    final images = message.images;
    if (images.isEmpty) return const SizedBox.shrink();

    if (images.length == 1) {
      return GestureDetector(
        onTap: () => _showFullImage(context, images),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 200,
              maxHeight: 200,
            ),
            child: Image.network(
              images[0],
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => _showFullImage(context, images),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 220,
              maxHeight: 220,
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: images.length == 2 ? 2 : 3,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
              ),
              itemCount: images.length > 9 ? 9 : images.length,
              itemBuilder: (context, index) {
                if (index == 8 && images.length > 9) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(images[index], fit: BoxFit.cover),
                      Container(
                        color: Colors.black45,
                        alignment: Alignment.center,
                        child: Text(
                          '+${images.length - 9}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return Image.network(
                  images[index],
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ),
      );
    }

  }

  void _showFullImage(BuildContext context, List<String> images) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black87,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: images.length,
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  child: Center(
                    child: Image.network(
                      images[index],
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
