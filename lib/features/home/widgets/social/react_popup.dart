import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/post/post_model.dart';
import '../../../../data/repositories/post_repository.dart';
import '../../../../data/services/apis/post_service.dart';

class ReactPopup extends StatefulWidget {
  final PostModel post;

  const ReactPopup({super.key, required this.post});

  @override
  State<ReactPopup> createState() => _ReactPopupState();
}

class _ReactPopupState extends State<ReactPopup> {
  late Future<PostModel> _fetchPostFuture;

  @override
  void initState() {
    super.initState();
    _fetchPostFuture = _loadPost();
  }

  Future<PostModel> _loadPost() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception("Missing token");

    final repo = PostRepository(PostService(ApiClient()));
    final res = await repo.getPostDetail(token: token, postId: widget.post.id);

    if (res.data == null) {
      throw Exception(res.message ?? "Failed to load post");
    }

    return res.data!;
  }

  static const Map<String, String> _reactionIcons = {
    'Like': 'like.png',
    'Love': 'heart.png',
    'Haha': 'haha.png',
    'Wow': 'surprised.png',
    'Sad': 'sad.png',
    'Angry': 'angry.png',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final secondaryText = isDark ? Colors.white54 : Colors.grey[700]!;
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate("react")),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<PostModel>(
          future: _fetchPostFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final post = snapshot.data!;
            final List<_UserReaction> allReactions = [];

            for (var reaction in post.reactions) {
              for (var user in reaction.users) {
                allReactions.add(
                  _UserReaction(user: user, type: reaction.reactionType),
                );
              }
            }

            if (allReactions.isEmpty) {
              return Center(
                child: Text(
                  loc.translate("no_react"),
                  style: TextStyle(color: secondaryText),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: allReactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final r = allReactions[index];
                final asset = _reactionIcons[r.type] ?? 'like.png';

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: r.user.avatarUrl.isNotEmpty
                          ? NetworkImage(r.user.avatarUrl)
                          : null,
                      child: r.user.avatarUrl.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        r.user.name,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Image.asset('assets/$asset', width: 28, height: 28),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _UserReaction {
  final PostUser user;
  final String type;

  _UserReaction({required this.user, required this.type});
}
