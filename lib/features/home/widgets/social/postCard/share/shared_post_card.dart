import 'package:flutter/material.dart';
import 'package:polygo_mobile/features/home/widgets/social/postCard/post/post_card_id.dart';
import 'package:polygo_mobile/features/home/widgets/social/postCard/post/post_images.dart';
import 'package:polygo_mobile/features/home/widgets/social/postCard/share/shared_container.dart';
import '../../../../../../core/utils/render_utils.dart';
import '../../../../../../data/models/post/post_model.dart';
import '../../../../../../core/localization/app_localizations.dart';

class SharedPostCard extends StatelessWidget {
  final SharedPostModel post;

  const SharedPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String _timeAgo(DateTime dateTime) {
      final diff = DateTime.now().difference(dateTime);
      if (diff.inSeconds < 60) return loc.translate("just_now");
      if (diff.inMinutes < 60) return '${diff.inMinutes} ${loc.translate("minutes_ago")}';
      if (diff.inHours < 24) return '${diff.inHours} ${loc.translate("hours_ago")}';
      if (diff.inDays < 7) return '${diff.inDays} ${loc.translate("days_ago")}';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} ${loc.translate("weeks_ago")}';
      if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} ${loc.translate("months_ago")}';
      return '${(diff.inDays / 365).floor()} ${loc.translate("year_ago")}';
    }

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => Dialog(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E1E1E)
                : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                child: PostCardById(
                  postId: post.id,
                  avatarUrl: post.creator.avatarUrl,
                  userName: post.creator.name,
                ),
              ),
            ),
          ),
        );
      },
      child: SharedContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(post.creator.avatarUrl),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.creator.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isDark ? Colors.white70 : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _timeAgo(post.createdAt),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (post.content.isNotEmpty)
              RenderUtils.selectableMarkdownText(context, post.content),
            if (post.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 8),
              PostImages(
                imageUrls: post.imageUrls,
                imageBgColors: List.generate(
                  post.imageUrls.length,
                      (_) => Colors.grey,
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
