import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_client.dart';
import '../../../../data/models/api_response.dart';
import '../../../../data/models/post/post_model.dart';
import '../../../../data/repositories/post_repository.dart';
import '../../../../data/services/apis/post_service.dart';
import '../../../core/localization/app_localizations.dart';
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
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    String timeAgo(DateTime dateTime) {
      final diff = DateTime.now().difference(dateTime);
      if (diff.inSeconds < 60) return loc.translate("just_now");
      if (diff.inMinutes < 60) {
        return '${diff.inMinutes} ${loc.translate("minutes_ago")}';
      }
      if (diff.inHours < 24) {
        return '${diff.inHours} ${loc.translate("hours_ago")}';
      }
      if (diff.inDays < 7) {
        return '${diff.inDays} ${loc.translate("days_ago")}';
      }
      if (diff.inDays < 30) {
        return '${(diff.inDays / 7).floor()} ${loc.translate("weeks_ago")}';
      }
      if (diff.inDays < 365) {
        return '${(diff.inDays / 30).floor()} ${loc.translate("months_ago")}';
      }
      return '${(diff.inDays / 365).floor()} ${loc.translate("year_ago")}';
    }

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          loc.translate('posts'),
          style: t.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: AppErrorState(onRetry: _loadPosts),
      )
          : RefreshIndicator(
        onRefresh: _loadPosts,
        child: ListView(
          padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          children: [
            ..._posts.map((post) {
              return PostCard(
                post: post,
                avatarUrl: post.creator.avatarUrl,
                userName: post.creator.name,
                timeAgo: timeAgo(post.createdAt),
                contentText: post.content,
                contentImage: post.imageUrls.isNotEmpty
                    ? post.imageUrls.first
                    : null,
                reactCount: post.reactionsCount,
                commentCount: post.commentsCount,
                onPostDeleted: (_) => _loadPosts(),
                onPostUpdated: (_) => _loadPosts(),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}