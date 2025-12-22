import 'package:flutter/material.dart';
import 'package:polygo_mobile/features/home/widgets/social/postCard/share/shared_event_card.dart';
import 'package:polygo_mobile/features/home/widgets/social/postCard/share/shared_post_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../core/api/api_client.dart';
import '../../../../../../core/localization/app_localizations.dart';
import '../../../../../../core/utils/audioplayers.dart';
import '../../../../../../data/models/post/post_model.dart';
import '../../../../../../data/repositories/post_repository.dart';
import '../../../../../../data/services/apis/post_service.dart';
import 'post_header.dart';
import 'post_content.dart';
import 'post_images.dart';
import 'post_footer.dart';
import 'reaction_bar.dart';
import 'post_utils.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final String avatarUrl;
  final String userName;
  final String timeAgo;
  final String? contentText;
  final String? contentImage;
  final int reactCount;
  final int commentCount;

  final void Function(String postId)? onPostDeleted;
  final void Function(PostModel updatedPost)? onPostUpdated;
  final void Function(String postId, String? newMyReaction)? onMyReactionChanged;

  const PostCard({
    super.key,
    required this.post,
    required this.avatarUrl,
    required this.userName,
    required this.timeAgo,
    this.contentText,
    this.contentImage,
    required this.reactCount,
    required this.commentCount,
    this.onPostDeleted,
    this.onPostUpdated,
    this.onMyReactionChanged,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late final PostRepository _postRepository;

  late int _reactCount;
  late int _commentCount;
  int? _selectedReaction;

  // List<Color?> _imageBgColors = [];

  @override
  void initState() {
    super.initState();

    _postRepository = PostRepository(PostService(ApiClient()));

    _reactCount = widget.reactCount;
    _commentCount = widget.commentCount;

    _selectedReaction = reactionIndexFromName(widget.post.myReaction);

    // _imageBgColors = List<Color?>.filled(widget.post.imageUrls.length, null);

    // Load dominant color for images
    // for (int i = 0; i < widget.post.imageUrls.length; i++) {
    //   getDominantColor(widget.post.imageUrls[i]).then((color) {
    //     if (!mounted) return;
    //     setState(() => _imageBgColors[i] = color);
    //   });
    // }
  }

  Future<void> _handleReaction(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final postId = widget.post.id;
    final selected = ReactionType.values[index];

    try {
      if (_selectedReaction == index) {
        CallSoundManager().playReactPost();
        await _postRepository.unReact(token: token, postId: postId);
        setState(() {
          _selectedReaction = null;
          if (_reactCount > 0) _reactCount--;
        });
        widget.onMyReactionChanged?.call(postId, null);
      } else {
        CallSoundManager().playReactPost();
        await _postRepository.react(token: token, postId: postId, reactionType: selected.name);
        setState(() {
          _reactCount += _selectedReaction == null ? 1 : 0;
          _selectedReaction = index;
        });
        widget.onMyReactionChanged?.call(postId, selected.name);
      }
    } catch (e) {
      print("Reaction error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)])
            : const LinearGradient(colors: [Colors.white, Colors.white]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PostHeader(
                post: widget.post,
                avatarUrl: widget.avatarUrl,
                userName: widget.userName,
                onPostDeleted: widget.onPostDeleted,
                onPostUpdated: widget.onPostUpdated,
              ),

              const SizedBox(height: 12),

              PostContent(contentText: widget.contentText),
              /// Render shared content (post hoặc event)
              if (widget.post.isShare) ...[
                const SizedBox(height: 8),
                _buildSharedContent(),
                const SizedBox(height: 12),
              ],

              PostImages(
                imageUrls: widget.post.imageUrls,
                // imageBgColors: _imageBgColors,
              ),

              const SizedBox(height: 12),

              PostFooter(
                commentCount: _commentCount,
                reactCount: _reactCount,
                post: widget.post,
                onCommentAdded: (newTotal) {
                  setState(() => _commentCount = newTotal);
                },
              ),

              const SizedBox(height: 16),

              ReactionBar(
                selectedReaction: _selectedReaction,
                onReactionTap: _handleReaction,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSharedContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);
    if (widget.post.shareType == "Post") {
      if (widget.post.sharedPost != null) return SharedPostCard(post: widget.post.sharedPost!);
      return _buildDeletedContainer(loc.translate('post_deleted'), isDark);
    }

    if (widget.post.shareType == "Event") {
      if (widget.post.sharedEvent != null) return SharedEventCard(event: widget.post.sharedEvent!);
      return _buildDeletedContainer(loc.translate('event_deleted'), isDark);
    }

    return const SizedBox.shrink();
  }

  Widget _buildDeletedContainer(String text, bool isDark) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: isDark ? Colors.black26 : Colors.grey[200],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontStyle: FontStyle.italic,
        color: isDark ? Colors.white70 : Colors.black54,
      ),
    ),
  );

}
