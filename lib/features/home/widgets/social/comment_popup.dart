import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/post/comment_model.dart';
import '../../../../data/models/post/post_model.dart';
import '../../../../data/models/post/update_comment_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/post_repository.dart';
import '../../../../data/services/apis/auth_service.dart';
import '../../../../data/services/apis/post_service.dart';

class CommentPopup extends StatefulWidget {
  final PostModel post;
  final void Function(int newCommentCount)? onCommentAdded;

  const CommentPopup({super.key, required this.post, this.onCommentAdded});

  @override
  State<CommentPopup> createState() => _CommentPopupState();
}

class _CommentPopupState extends State<CommentPopup> {
  final TextEditingController _commentController = TextEditingController();
  bool _hasText = false;
  String? _userAvatar;
  Map<String, TextEditingController> _editingControllers = {};
  Set<String> _editingComments = {};
  Set<String> _hasTextChanged = {};

  bool _isLoading = true;
  PostModel? _postDetail;

  late final PostRepository _postRepo;

  @override
  void initState() {
    super.initState();
    _postRepo = PostRepository(PostService(ApiClient()));

    _commentController.addListener(() {
      setState(() {
        _hasText = _commentController.text.trim().isNotEmpty;
      });
    });

    _loadUserAvatar();
    _fetchPostDetail();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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
      debugPrint('Avatar error: $e');
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final loc = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.translate("confirm")),
        content: Text(loc.translate("you_sure_delete_cmt")),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(loc.translate("cancel")),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              loc.translate("delete"),
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final res = await _postRepo.deleteComment(
        token: token,
        commentId: commentId,
      );

      if (res.message?.contains("Success.Delete") == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate("delete_cmt_success"))),
        );
        await _fetchPostDetail();
        widget.onCommentAdded?.call(_postDetail?.comments.length ?? 0);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.message ?? loc.translate("delete_cmt_failed")),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate("delete_cmt_failed"))),
      );
    }
  }

  /// ⬇️ Lấy detail post từ API
  Future<void> _fetchPostDetail() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception("Missing token");

      final res = await _postRepo.getPostDetail(
        token: token,
        postId: widget.post.id,
      );

      if (!mounted) return;

      setState(() {
        _postDetail = res.data!;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Load post detail failed: $e");
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      // tạo request
      final request = CreateCommentRequest(content: content);

      // gọi API
      final res = await _postRepo.commentPost(
        token: token,
        postId: widget.post.id,
        request: request,
      );

      if (res.data != null) {
        _commentController.clear();
        await _fetchPostDetail();
        widget.onCommentAdded?.call(_postDetail?.comments.length ?? 0);
      } else {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message ?? loc.translate("cmt_failed"))),
        );
      }
    } catch (e) {
      debugPrint("Send comment failed: $e");
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.translate("cmt_failed"))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white70 : Colors.black87;
    final Color secondaryText = isDark ? Colors.white54 : Colors.grey[700]!;
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color inputBgColor = isDark ? Colors.white12 : Colors.grey[200]!;
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          loc.translate("comments"),
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        ),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),

      // BODY
      body: SafeArea(
        child: Column(
          children: [
            // input comment
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey,
                    backgroundImage: _userAvatar != null
                        ? NetworkImage(_userAvatar!)
                        : null,
                    child: _userAvatar == null
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: loc.translate("write_comment"),
                        hintStyle: TextStyle(color: secondaryText),
                        filled: true,
                        fillColor: inputBgColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_hasText)
                    ElevatedButton(
                      onPressed: _sendComment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(12),
                        minimumSize: const Size(40, 40),
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),

            Divider(color: Colors.grey.withOpacity(0.3), thickness: 1),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _postDetail == null
                  ? Center(child: Text(loc.translate("load_cmt_error")))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      itemCount: _postDetail!.comments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final comment = _postDetail!.comments[index];

                        final isEditing = _editingComments.contains(comment.id);
                        final controller = _editingControllers.putIfAbsent(
                          comment.id,
                          () => TextEditingController(text: comment.content),
                        );

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundImage: comment.user.avatarUrl.isNotEmpty
                                  ? NetworkImage(comment.user.avatarUrl)
                                  : null,
                              backgroundColor: Colors.grey,
                              child: comment.user.avatarUrl.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 36),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isDark
                                              ? Colors.black.withOpacity(0.1)
                                              : Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment.user.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),

                                        // Nếu đang chỉnh sửa -> show TextField
                                        isEditing
                                            ? Row(
                                                children: [
                                                  Expanded(
                                                    child: TextField(
                                                      controller: controller,
                                                      maxLines: null,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          if (value.trim() !=
                                                              comment.content) {
                                                            _hasTextChanged.add(
                                                              comment.id,
                                                            );
                                                          } else {
                                                            _hasTextChanged
                                                                .remove(
                                                                  comment.id,
                                                                );
                                                          }
                                                        });
                                                      },
                                                      decoration: InputDecoration(
                                                        hintText: loc.translate(
                                                          "edit_cmt",
                                                        ),
                                                        border: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                          borderSide:
                                                              BorderSide.none,
                                                        ),
                                                        fillColor: inputBgColor,
                                                        filled: true,
                                                        contentPadding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 8,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                  // Nút Cancel luôn hiển thị
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.cancel,
                                                      color: Colors.grey,
                                                      size: 20,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _editingComments.remove(
                                                          comment.id,
                                                        );
                                                        _hasTextChanged.remove(
                                                          comment.id,
                                                        );
                                                        controller
                                                            .text = comment
                                                            .content; // reset nội dung
                                                      });
                                                    },
                                                  ),
                                                  // Nút Send chỉ hiển thị khi có thay đổi
                                                  if (_hasTextChanged.contains(
                                                    comment.id,
                                                  ))
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.send,
                                                        color: Colors.blue,
                                                        size: 20,
                                                      ),
                                                      onPressed: () async {
                                                        final prefs =
                                                            await SharedPreferences.getInstance();
                                                        final token = prefs
                                                            .getString('token');
                                                        if (token == null)
                                                          return;

                                                        final newContent =
                                                            controller.text
                                                                .trim();
                                                        if (newContent.isEmpty)
                                                          return;

                                                        try {
                                                          final res = await _postRepo
                                                              .updateComment(
                                                                token: token,
                                                                commentId:
                                                                    comment.id,
                                                                request:
                                                                    UpdateCommentRequest(
                                                                      content:
                                                                          newContent,
                                                                    ),
                                                              );

                                                          if (res.message?.contains(
                                                                "Success.Update",
                                                              ) ==
                                                              true) {
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  loc.translate(
                                                                    "edit_cmt_success",
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                            _editingComments
                                                                .remove(
                                                                  comment.id,
                                                                );
                                                            _hasTextChanged
                                                                .remove(
                                                                  comment.id,
                                                                );
                                                            await _fetchPostDetail();
                                                          } else {
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  res.message ??
                                                                      loc.translate(
                                                                        "edit_cmt_failed",
                                                                      ),
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        } catch (e) {
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                loc.translate(
                                                                  "edit_cmt_failed",
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                    ),
                                                ],
                                              )
                                            : Text(
                                                comment.content,
                                                style: TextStyle(
                                                  color: textColor,
                                                ),
                                              ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _timeAgo(comment.createdAt),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Positioned(
                                    top: 4,
                                    right: 0,
                                    child: comment.isMyComment
                                        ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              PopupMenuButton<String>(
                                                icon: Icon(
                                                  Icons.settings,
                                                  color: isDark
                                                      ? Colors.white54
                                                      : Colors.grey,
                                                ),
                                                offset: const Offset(0, 40),
                                                onSelected: (value) {
                                                  if (value == 'edit') {
                                                    setState(() {
                                                      _editingComments.add(
                                                        comment.id,
                                                      );
                                                    });
                                                  } else if (value ==
                                                      'delete') {
                                                    _deleteComment(comment.id);
                                                  }
                                                },
                                                itemBuilder: (context) => [
                                                  PopupMenuItem(
                                                    value: 'edit',
                                                    child: Text(
                                                      loc.translate("edit"),
                                                    ),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'delete',
                                                    child: Text(
                                                      loc.translate("delete"),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                        : const SizedBox(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    final loc = AppLocalizations.of(context);
    if (diff.inSeconds < 60) return loc.translate("just_now");
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} ${loc.translate("minutes_ago")}';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} ${loc.translate("hours_ago")}';
    }
    if (diff.inDays < 7) return '${diff.inDays} ${loc.translate("days_ago")}';
    if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()} ${loc.translate("weeks_ago")}';
    }
    if (diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()} ${loc.translate("months_ago")}';
    }
    return '${(diff.inDays / 365).floor()} ${loc.translate("year_ago")}';
  }
}
