import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:polygo_mobile/features/home/widgets/social/postCard/post/post_card_id.dart';
import 'package:polygo_mobile/features/home/widgets/social/postCard/post/post_images.dart';
import 'package:polygo_mobile/features/home/widgets/social/postCard/share/shared_container.dart';
import '../../../../../../core/utils/render_utils.dart';
import '../../../../../../data/models/post/post_model.dart';
import '../../../../../../core/localization/app_localizations.dart';

class SharedPostCard extends StatelessWidget {
  final SharedPostModel post;

  const SharedPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String _timeAgo(DateTime dateTime) {
      final diff = DateTime.now().difference(dateTime);
      if (diff.inSeconds < 60) return loc.translate("just_now");
      if (diff.inMinutes < 60) return '${diff.inMinutes} ${loc.translate("minutes_ago")}';
      if (diff.inHours < 24) return '${diff.inHours} ${loc.translate("hours_ago")}';
      if (diff.inDays < 7) return '${diff.inDays} ${loc.translate("days_ago")}';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} ${loc.translate("weeks_ago")}';
      if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} ${loc.translate("months_ago")}';
      return '${(diff.inDays / 365).floor()} ${loc.translate("year_ago")}';
    }

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => Dialog(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E1E1E)
                : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                child: PostCardById(
                  postId: post.id,
                  avatarUrl: post.creator.avatarUrl,
                  userName: post.creator.name,
                ),
              ),
            ),
          ),
        );
      },
      child: SharedContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(post.creator.avatarUrl),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.creator.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isDark ? Colors.white70 : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _timeAgo(post.createdAt),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (post.content.isNotEmpty)
              LimitedMarkdown(
                data: post.content,
                maxLines: 10,
              ),
            if (post.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 8),
              PostImages(
                imageUrls: post.imageUrls,
                imageBgColors: List.generate(
                  post.imageUrls.length,
                      (_) => Colors.grey,
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}

class LimitedMarkdown extends StatefulWidget {
  final String data;
  final int maxLines;

  const LimitedMarkdown({super.key, required this.data, this.maxLines = 10});

  @override
  State<LimitedMarkdown> createState() => _LimitedMarkdownState();
}

class _LimitedMarkdownState extends State<LimitedMarkdown> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final decoded = RenderUtils.decodeHtml(widget.data);
    final style = DefaultTextStyle.of(context).style;

    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white60
        : Colors.black87;

    final markdownStyle = MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: TextStyle(color: textColor),
      strong: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      a: const TextStyle(color: Colors.blue),
    );

    if (_expanded) {
      return MarkdownBody(
        data: decoded,
        selectable: true,
        styleSheet: markdownStyle,
      );
    }

    final tp = TextPainter(
      text: TextSpan(text: decoded, style: style.copyWith(color: textColor)),
      maxLines: widget.maxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: MediaQuery.of(context).size.width - 32);

    if (!tp.didExceedMaxLines) {
      return MarkdownBody(
        data: decoded,
        selectable: true,
        styleSheet: markdownStyle,
      );
    }

    final endIndex = tp.getPositionForOffset(Offset(tp.width, tp.height)).offset;
    final visibleText = decoded.substring(0, endIndex).trim();
    final loc = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MarkdownBody(
          data: visibleText + "...",
          selectable: true,
          styleSheet: markdownStyle,
        ),
        GestureDetector(
          onTap: () => setState(() => _expanded = true),
          child: Text(
            loc.translate('read_more'),
            style: TextStyle(
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
