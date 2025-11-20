import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../core/api/api_client.dart';
import '../../../../../../data/models/post/post_model.dart';
import '../../../../../../data/repositories/post_repository.dart';
import '../../../../../../data/services/apis/post_service.dart';
import 'post_header.dart';
import 'post_content.dart';
import 'post_images.dart';
import 'post_footer.dart';
import 'reaction_bar.dart';
import 'post_utils.dart';
import '../share/shared_event_card.dart';
import '../share/shared_post_card.dart';

class PostCardById extends StatefulWidget {
  final String postId;
  final String avatarUrl;
  final String userName;

  final void Function(String postId)? onPostDeleted;
  final void Function(PostModel updatedPost)? onPostUpdated;
  final void Function(String postId, String? newMyReaction)? onMyReactionChanged;

  const PostCardById({
    super.key,
    required this.postId,
    required this.avatarUrl,
    required this.userName,
    this.onPostDeleted,
    this.onPostUpdated,
    this.onMyReactionChanged,
  });

  @override
  State<PostCardById> createState() => _PostCardByIdState();
}

class _PostCardByIdState extends State<PostCardById> {
  late final PostRepository _postRepository;

  PostModel? _post;
  bool _loading = true;

  int _reactCount = 0;
  int _commentCount = 0;
  int? _selectedReaction;
  List<Color?> _imageBgColors = [];

  @override
  void initState() {
    super.initState();
    _postRepository = PostRepository(PostService(ApiClient()));
    _fetchPost();
  }

  Future<void> _fetchPost() async {
    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    if (token.isEmpty) return;

    try {
      final response = await _postRepository.getPostDetail(
        token: token,
        postId: widget.postId,
      );

      final post = response.data;

      // Load dominant colors for images
      final imageColors = List<Color?>.filled(post!.imageUrls.length, null);
      for (int i = 0; i < post.imageUrls.length; i++) {
        getDominantColor(post.imageUrls[i]).then((color) {
          if (!mounted) return;
          setState(() => imageColors[i] = color);
        });
      }

      if (!mounted) return;
      setState(() {
        _post = post;
        _reactCount = post.reactionsCount;
        _commentCount = post.commentsCount;
        _selectedReaction = reactionIndexFromName(post.myReaction);
        _imageBgColors = imageColors;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      print("Error loading post: $e");
    }
  }

  Future<void> _handleReaction(int index) async {
    if (_post == null) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final postId = _post!.id;
    final selected = ReactionType.values[index];

    try {
      if (_selectedReaction == index) {
        await _postRepository.unReact(token: token, postId: postId);
        setState(() {
          _selectedReaction = null;
          if (_reactCount > 0) _reactCount--;
        });
        widget.onMyReactionChanged?.call(postId, null);
      } else {
        await _postRepository.react(
          token: token,
          postId: postId,
          reactionType: selected.name,
        );
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

    if (_loading || _post == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final post = _post!;

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
                post: post,
                avatarUrl: widget.avatarUrl,
                userName: widget.userName,
                onPostDeleted: widget.onPostDeleted,
                onPostUpdated: widget.onPostUpdated,
              ),
              const SizedBox(height: 12),
              PostContent(contentText: post.content),
              if (post.isShare) ...[
                const SizedBox(height: 8),
                if (post.sharedPost != null)
                  SharedPostCard(post: post.sharedPost!),
                if (post.sharedEvent != null)
                  SharedEventCard(event: post.sharedEvent!),
                const SizedBox(height: 12),
              ],
              PostImages(
                imageUrls: post.imageUrls,
                imageBgColors: _imageBgColors,
              ),
              const SizedBox(height: 12),
              PostFooter(
                commentCount: _commentCount,
                reactCount: _reactCount,
                post: post,
                onCommentAdded: (newTotal) {
                  setState(() => _commentCount = newTotal);
                },
              ),
              const SizedBox(height: 16),
              ReactionBar(
                selectedReaction: _selectedReaction,
                onReactionTap: _handleReaction,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
