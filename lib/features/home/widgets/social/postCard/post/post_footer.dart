import 'package:flutter/material.dart';
import 'package:polygo_mobile/features/home/widgets/social/postCard/share/share_dialog.dart';
import '../../../../../../core/localization/app_localizations.dart';
import '../../comment_popup.dart';
import '../../react_popup.dart';
import '../../../../../../data/models/post/post_model.dart';

class PostFooter extends StatelessWidget {
  final int reactCount;
  final int commentCount;
  final PostModel post;
  final Function(int newCount) onCommentAdded;

  const PostFooter({
    super.key,
    required this.reactCount,
    required this.commentCount,
    required this.post,
    required this.onCommentAdded,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ReactPopup(post: post)),
          ),
          child: Row(
            children: [
              Icon(Icons.thumb_up_alt_outlined, size: 20),
              const SizedBox(width: 4),
              Text("$reactCount"),
            ],
          ),
        ),
        const SizedBox(width: 25),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CommentPopup(
                  post: post,
                  onCommentAdded: (count) => onCommentAdded(count),
                ),
              ),
            );
          },
          child: Row(
            children: [
              Icon(Icons.mode_comment_outlined,
                  size: 20, color: isDark ? Colors.white70 : Colors.grey),
              const SizedBox(width: 4),
              Text("$commentCount"),
            ],
          ),
        ),
        const Spacer(),
        IconButton(
          icon: Icon(Icons.share, size: 20, color: isDark ? Colors.white54 : Colors.grey),
          onPressed: () async {
            final result = await showDialog(
              context: context,
              builder: (_) => SharePostDialog(
                post: post,
                isShare: post.isShare,
                shareType: post.isShare && post.sharedPost != null ? "Post" : post.isShare && post.sharedEvent != null ? "Event" : "Post",
              ),
            );

            if (result != null && result is PostModel) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.translate('post_share_success'))),
              );
            }
          },
        ),
      ],
    );
  }
}
