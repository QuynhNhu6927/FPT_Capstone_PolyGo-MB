import 'package:flutter/material.dart';
import 'package:polygo_mobile/core/utils/string_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_client.dart';
import '../../../../data/models/api_response.dart';
import '../../../../data/models/post/post_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/post_repository.dart';
import '../../../../data/services/apis/auth_service.dart';
import '../../../../data/services/apis/post_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../home/widgets/social/create_post_dialog.dart';
import '../../home/widgets/social/postCard/post/post_card.dart';
import '../../shared/app_error_state.dart';

class MyPostContent extends StatefulWidget {
  final String searchQuery;
  const MyPostContent({super.key, this.searchQuery = ''});

  @override
  State<MyPostContent> createState() => _MyPostContentState();
}

class _MyPostContentState extends State<MyPostContent> {
  String? selectedImage;
  String? _userAvatar;
  bool _loading = true;
  String? _error;
  List<PostModel> _posts = [];
  late PostRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = PostRepository(PostService(ApiClient()));
    _loadUserAvatar();
    _loadPosts();
  }

  Future<void> _loadUserAvatar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final repo = AuthRepository(AuthService(ApiClient()));
      final user = await repo.me(token);
      if (!mounted) return;

      setState(() {
        _userAvatar = user.avatarUrl;
      });
    } catch (e) {
      //
    }
  }

  Future<void> _openCreatePostDialog() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreatePostDialog(
          userAvatar: _userAvatar,
          onPosted: () {},
        ),
      ),
    );

    if (result == true) {
      await _loadPosts();
      if (mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('create_post_success'))),
        );
      }
    }
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
      await _repo.getMyPosts(token: token);

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

  List<PostModel> get _displayedPosts {
    final query = widget.searchQuery.trim();
    if (query.isEmpty) return _posts;

    return _posts.where((e) => e.content.fuzzyContains(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = Theme.of(context).textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    String timeAgo(DateTime dateTime) {
      final diff = DateTime.now().difference(dateTime);
      if (diff.inSeconds < 60) return loc.translate("just_now");
      if (diff.inMinutes < 60) return '${diff.inMinutes} ${loc.translate("minutes_ago")}';
      if (diff.inHours < 24) return '${diff.inHours} ${loc.translate("hours_ago")}';
      if (diff.inDays < 7) return '${diff.inDays} ${loc.translate("days_ago")}';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} ${loc.translate("weeks_ago")}';
      if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} ${loc.translate("months_ago")}';
      return '${(diff.inDays / 365).floor()} ${loc.translate("year_ago")}';
    }

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          loc.translate('my_posts'),
          style: t.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: AppErrorState(onRetry: _loadPosts),
      )
          : RefreshIndicator(
        onRefresh: _loadPosts,
        child: ListView(
          padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          children: [
            _buildCreatePostBox(context, isDark, t),
            const SizedBox(height: 16),
            Divider(
              color: Colors.grey.withOpacity(0.3),
              thickness: 1,
            ),
            const SizedBox(height: 16),
            ..._displayedPosts.map((post) {
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
                onPostDeleted: (postId) async {
                  await _loadPosts();
                },
                onPostUpdated: (updatedPost) async {
                  await _loadPosts();
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatePostBox(BuildContext context, bool isDark, TextTheme t) {
    final Color textColor = isDark ? Colors.white70 : Colors.black87;
    final Color secondaryText = isDark ? Colors.white54 : Colors.grey[700]!;
    final loc = AppLocalizations.of(context);

    final Gradient cardBackground = isDark
        ? const LinearGradient(
      colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(colors: [Colors.white, Colors.white]);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.translate("share_your_though"),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey,
                backgroundImage:
                _userAvatar != null ? NetworkImage(_userAvatar!) : null,
                child: _userAvatar == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: _openCreatePostDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 14),
                    decoration: BoxDecoration(
                      color:
                      isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      loc.translate("share_your_though"),
                      style: TextStyle(color: secondaryText, fontSize: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _openCreatePostDialog,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                    color:
                    isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.image_outlined,
                    color: isDark ? Colors.white70 : Colors.grey[800],
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
