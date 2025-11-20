import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polygo_mobile/features/home/widgets/social/postCard/share/shared_container.dart';
import 'package:polygo_mobile/features/home/widgets/social/postCard/share/shared_event_detail.dart';

import '../../../../../../core/utils/render_utils.dart';
import '../../../../../../data/models/post/post_model.dart';

class SharedEventCard extends StatelessWidget {
  final SharedEventModel event;

  const SharedEventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return SharedEventDetail(
              sharedEventId: event.id,
            );
          },
        );
      },
      child: SharedContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header host
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(event.host.avatarUrl),
                ),
                const SizedBox(width: 10),
                Text(
                  event.host.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white70 : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            /// Title
            RenderUtils.selectableMarkdownText(context, event.title),

            const SizedBox(height: 8),

            /// Banner
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildBanner(),
            ),

            const SizedBox(height: 8),

            /// StartAt Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formatDate(event.startAt),
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return "${dt.day}/${dt.month}/${dt.year} • "
        "${dt.hour.toString().padLeft(2, "0")}:"
        "${dt.minute.toString().padLeft(2, "0")}";
  }

  Widget _buildBanner() {
    if (event.bannerUrl == null || event.bannerUrl!.isEmpty) {
      return Container(
        height: 180,
        width: double.infinity,
        color: Colors.grey.shade300,
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_not_supported,
          size: 48,
          color: Colors.grey,
        ),
      );
    }
    return Image.network(
      event.bannerUrl!,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: 180,
        width: double.infinity,
        color: Colors.grey.shade300,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
      ),
    );
  }
}
