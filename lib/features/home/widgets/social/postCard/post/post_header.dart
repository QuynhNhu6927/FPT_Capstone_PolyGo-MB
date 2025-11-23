import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../core/api/api_client.dart';
import '../../../../../../core/localization/app_localizations.dart';
import '../../../../../../data/models/post/post_model.dart';
import '../../../../../../data/repositories/post_repository.dart';
import '../../../../../../data/services/apis/post_service.dart';
import '../../../../../../routes/app_routes.dart';
import '../../report_post_dialog.dart';
import '../../update_post_dialog.dart';

class PostHeader extends StatelessWidget {
  final PostModel post;
  final String avatarUrl;
  final String userName;

  final void Function(String postId)? onPostDeleted;
  final void Function(PostModel p)? onPostUpdated;

  const PostHeader({
    super.key,
    required this.post,
    required this.avatarUrl,
    required this.userName,
    this.onPostDeleted,
    this.onPostUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Future<void> _deletePost(BuildContext context, PostModel post, void Function(String)? onPostDeleted) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final loc = AppLocalizations.of(context);

      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(loc.translate("confirm")),
          content: Text(loc.translate("confirm_delete_post")),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(loc.translate('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                loc.translate("delete"),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      try {
        final repo = PostRepository(PostService(ApiClient()));
        final response = await repo.deletePost(token: token, postId: post.id);

        if (response.message?.contains("Success") == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.translate("delete_post_success"))),
          );
          onPostDeleted?.call(post.id);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message ?? loc.translate("delete_post_failed"))),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate("delete_post_failed"))),
        );
      }
    }

    String _timeAgo(DateTime dateTime) {
      final diff = DateTime.now().difference(dateTime);
      final loc = AppLocalizations.of(context);
      if (diff.inSeconds < 60) return loc.translate("just_now");
      if (diff.inMinutes < 60) return '${diff.inMinutes} ${loc.translate("minutes_ago")}';
      if (diff.inHours < 24) return '${diff.inHours} ${loc.translate("hours_ago")}';
      if (diff.inDays < 7) return '${diff.inDays} ${loc.translate("days_ago")}';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} ${loc.translate("weeks_ago")}';
      if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} ${loc.translate("months_ago")}';
      return '${(diff.inDays / 365).floor()} ${loc.translate("year_ago")}';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: post.isMyPost
              ? null
              : () {
            Navigator.pushNamed(
              context,
              AppRoutes.userProfile,
              arguments: {'id': post.creator.id},
            );
          },
          child: CircleAvatar(
            radius: 22,
            backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
            backgroundColor: Colors.grey[700],
            child: avatarUrl.isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tên user + số ảnh nếu có
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: userName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isDark ? Colors.white70 : Colors.black,
                          ),
                        ),
                        if (post.isShare && post.shareType != null) ...[
                          TextSpan(text: ' - '),
                          TextSpan(
                            text: post.shareType == "Event"
                                ? loc.translate("share_an_event")
                                : loc.translate("share_an_post"),
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 13,
                              color: isDark ? Colors.white54 : Colors.grey[700],
                            ),
                          ),
                        ],
                        if (post.imageUrls.isNotEmpty) ...[
                          TextSpan(text: ' - '),
                          TextSpan(
                            text: '${loc.translate("has_post_img")} ${post.imageUrls.length} ${loc.translate("img")}',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 13,
                              color: isDark ? Colors.white54 : Colors.grey[700],
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                ],
              ),

              const SizedBox(height: 4),
              Text(
                _timeAgo(post.createdAt),
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),

        // Nút edit/delete hoặc flag
        post.isMyPost
            ? PopupMenuButton<String>(
          icon: Icon(Icons.settings, color: isDark ? Colors.white54 : Colors.grey),
          offset: const Offset(-10, 40),
          onSelected: (value) async {
            if (value == "edit") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UpdatePostDialog(
                    userAvatar: avatarUrl,
                    postId: post.id,
                    onUpdated: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final token = prefs.getString('token');
                      if (token == null) return;

                      final repo = PostRepository(PostService(ApiClient()));
                      final res = await repo.getPostDetail(token: token, postId: post.id);

                      if (res.data != null) onPostUpdated?.call(res.data!);
                    },
                  ),
                ),
              );
            }
            if (value == "delete") {
              _deletePost(context, post, onPostDeleted);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: "edit", child: Text(loc.translate("edit"))),
            PopupMenuItem(value: "delete", child: Text(loc.translate("delete"))),
          ],
        )
            : GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => ReportPostDialog(
                postId: post.id,
                onSubmit: () {

                },
              ),
            );
          },
          child: Icon(
            Icons.flag_outlined,
            color: isDark ? Colors.white54 : Colors.grey,
          ),
        ),
      ],
    );
  }
}
