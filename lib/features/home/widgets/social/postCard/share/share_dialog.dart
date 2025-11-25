import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../core/localization/app_localizations.dart';
import '../../../../../../core/utils/audioplayers.dart';
import '../../../../../../core/widgets/app_button.dart';
import '../../../../../../data/models/post/post_model.dart';
import '../../../../../../data/models/post/share_request_model.dart';
import '../../../../../../data/repositories/post_repository.dart';
import '../../../../../../data/services/apis/post_service.dart';
import '../../../../../../core/api/api_client.dart';

class SharePostDialog extends StatefulWidget {
  final PostModel post;
  final bool isShare;
  final String? shareType;
  final String? userAvatar;

  const SharePostDialog({
    super.key,
    required this.post,
    this.isShare = false,
    this.shareType,
    this.userAvatar,
  });

  @override
  State<SharePostDialog> createState() => _SharePostDialogState();
}

class _SharePostDialogState extends State<SharePostDialog> {
  final TextEditingController _contentController = TextEditingController();
  bool _loading = false;

  late final PostRepository _postRepository;

  @override
  void initState() {
    super.initState();
    _postRepository = PostRepository(PostService(ApiClient()));
  }

  Future<void> _sharePost() async {
    setState(() => _loading = true);
    final loc = AppLocalizations.of(context);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    if (token.isEmpty) return;

    String shareType = "Post";
    String targetId = widget.post.id;

    if (widget.isShare) {
      shareType = widget.shareType ?? "Post";
      if (shareType == "Post" && widget.post.sharedPost != null) {
        targetId = widget.post.sharedPost!.id;
      } else if (shareType == "Event" && widget.post.sharedEvent != null) {
        targetId = widget.post.sharedEvent!.id;
      }
    }

    final request = SharePostRequest(
      shareType: shareType,
      targetId: targetId,
      content: _contentController.text,
    );

    try {
      final response = await _postRepository.sharePost(
        token: token,
        request: request,
      );

      if (response.data != null) {
        CallSoundManager().playReactPost();
        Navigator.of(context).pop(response.data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? loc.translate("share_post_failed"))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate("share_error"))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white70 : Colors.black87;
    final Color secondaryText = isDark ? Colors.white54 : Colors.grey[700]!;
    final Gradient cardBackground = isDark
        ? const LinearGradient(
      colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(colors: [Colors.white, Colors.white]);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: loc.translate("share_caption"),
                      hintStyle: TextStyle(color: secondaryText),
                      filled: true,
                      fillColor:
                      isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: AppButton(
                text: loc.translate("share"),
                onPressed: _loading ? null : _sharePost,
                size: ButtonSize.sm,
                variant: ButtonVariant.primary,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
