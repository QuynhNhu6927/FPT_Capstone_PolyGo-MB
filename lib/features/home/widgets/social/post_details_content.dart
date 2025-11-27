import 'package:flutter/material.dart';
import 'package:polygo_mobile/core/utils/string_extensions.dart';
import 'package:polygo_mobile/features/home/widgets/social/postCard/post/post_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/api_response.dart';
import '../../../../data/models/post/post_model.dart';
import '../../../../data/repositories/post_repository.dart';
import '../../../../data/services/apis/post_service.dart';
import '../../../shared/app_error_state.dart';

class PostDetailsContent extends StatefulWidget {
  final String postId;
  const PostDetailsContent({super.key, required this.postId});

  @override
  State<PostDetailsContent> createState() => _PostDetailsContentState();
}

class _PostDetailsContentState extends State<PostDetailsContent> {
  bool _loading = true;
  String? _error;
  PostModel? _post;
  late PostRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = PostRepository(PostService(ApiClient()));
    _loadPost();
  }

  Future<void> _loadPost() async {
    setState(() {
      _loading = true;
      _error = null;
      _post = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception("Token not found");

      final ApiResponse<PostModel> response =
      await _repo.getPostDetail(token: token, postId: widget.postId);

      if (!mounted) return;

      if (response.data != null) {
        setState(() {
          _post = response.data;
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

  String _timeAgo(DateTime dateTime) {
    final loc = AppLocalizations.of(context);
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return loc.translate("just_now");
    if (diff.inMinutes < 60) return '${diff.inMinutes} ${loc.translate("minutes_ago")}';
    if (diff.inHours < 24) return '${diff.inHours} ${loc.translate("hours_ago")}';
    if (diff.inDays < 7) return '${diff.inDays} ${loc.translate("days_ago")}';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} ${loc.translate("weeks_ago")}';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} ${loc.translate("months_ago")}';
    return '${(diff.inDays / 365).floor()} ${loc.translate("year_ago")}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final loc = AppLocalizations.of(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            loc.translate("post_details"),
            style: t.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: AppErrorState(
            onRetry: _loadPost,
          ),
        )
            : _post == null
            ? Center(
          child: Text(loc.translate("no_post_found")),
        )
            : ListView(
          padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          children: [
            PostCard(
              post: _post!,
              avatarUrl: _post!.creator.avatarUrl,
              userName: _post!.creator.name,
              timeAgo: _timeAgo(_post!.createdAt),
              contentText: _post!.content,
              contentImage: _post!.imageUrls.isNotEmpty
                  ? _post!.imageUrls.first
                  : null,
              reactCount: _post!.reactionsCount,
              commentCount: _post!.commentsCount,
              onPostDeleted: (postId) async => await _loadPost(),
              onPostUpdated: (updatedPost) async => await _loadPost(),
            ),
          ],
        ),
      ),
    );
  }
}
