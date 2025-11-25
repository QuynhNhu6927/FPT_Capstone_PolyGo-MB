import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../../../core/localization/app_localizations.dart';
import '../../../../../../core/utils/render_utils.dart';

class PostContent extends StatelessWidget {
  final String? contentText;

  const PostContent({super.key, this.contentText});

  @override
  Widget build(BuildContext context) {
    if (contentText == null || contentText!.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LimitedMarkdown(
        maxLines: 10,
        data: contentText!,
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

    // Tự động đổi màu theo dark/light mode
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
    final loc = AppLocalizations.of(context);
    final endIndex = tp.getPositionForOffset(Offset(tp.width, tp.height)).offset;
    final visibleText = decoded.substring(0, endIndex).trim();

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
            loc.translate("read_more"),
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
