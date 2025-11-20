import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_client.dart';
import '../../../../data/models/api_response.dart';
import '../../../../data/models/post/post_model.dart';
import '../../../../data/repositories/post_repository.dart';
import '../../../../data/services/apis/post_service.dart';
import '../../home/widgets/social/postCard/post/post_card.dart';
import '../../home/widgets/social/post_card_old.dart';
import '../../shared/app_error_state.dart';

class UserPostContent extends StatefulWidget {
  final String userId;
  const UserPostContent({super.key, required this.userId});

  @override
  State<UserPostContent> createState() => _UserPostContentState();
}

class _UserPostContentState extends State<UserPostContent> {
  bool _loading = true;
  String? _error;
  List<PostModel> _posts = [];
  late PostRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = PostRepository(PostService(ApiClient()));
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception("Token not found");

      final ApiResponse<PostPaginationResponse> response =
      await _repo.getUserPosts(token: token, userId: widget.userId);

      if (!mounted) return;

      if (response.data != null) {
        setState(() {
          _posts = response.data!.items;
          _loading = false;
        });
      } else {
        setState(() {
          _error = response.message ?? "Lỗi không xác định";
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: AppErrorState(onRetry: _loadPosts),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _posts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (context, index) {
          final post = _posts[index];
          return PostCard(
            post: post,
            avatarUrl: post.creator.avatarUrl,
            userName: post.creator.name,
            timeAgo:
            "${DateTime.now().difference(post.createdAt).inHours} giờ trước",
            contentText: post.content,
            contentImage:
            post.imageUrls.isNotEmpty ? post.imageUrls.first : null,
            reactCount: post.reactionsCount,
            commentCount: post.commentsCount,
            onPostDeleted: (_) => _loadPosts(),
            onPostUpdated: (_) => _loadPosts(),
          );
        },
      ),
    );
  }
}
