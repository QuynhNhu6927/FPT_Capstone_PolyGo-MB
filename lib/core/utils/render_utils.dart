import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:url_launcher/url_launcher.dart';

class RenderUtils {
  static String decodeHtml(String? htmlText) {
    if (htmlText == null || htmlText.isEmpty) return '';
    return HtmlUnescape().convert(htmlText);
  }

  static MarkdownStyleSheet _baseStyleSheet(BuildContext context, {TextStyle? style}) {
    final theme = Theme.of(context);
    final textColor = style?.color ?? (theme.brightness == Brightness.dark ? Colors.white70 : Colors.black87);

    return MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: TextStyle(fontSize: 14, color: textColor),
      h1: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
      h2: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
      h3: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
      h4: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
      em: TextStyle(fontStyle: FontStyle.italic, color: textColor),
      strong: TextStyle(fontWeight: FontWeight.bold, color: textColor),
      a: TextStyle(color: Colors.blueAccent, decoration: TextDecoration.underline),
      blockquote: TextStyle(
        color: theme.brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[700],
        backgroundColor: theme.brightness == Brightness.dark ? Colors.white10 : Colors.black12,
        fontStyle: FontStyle.italic,
      ),
      code: TextStyle(
        backgroundColor: theme.brightness == Brightness.dark ? Colors.white12 : Colors.black12,
        fontFamily: 'monospace',
      ),
      listBullet: TextStyle(fontSize: 14, color: textColor),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.brightness == Brightness.dark ? Colors.white30 : Colors.black26,
            width: 1,
          ),
        ),
      ),
    );
  }

  static Widget markdownText(
      BuildContext context,
      String? data, {
        TextStyle? style,
        MarkdownStyleSheet? styleSheet,
        bool selectable = false,
      }) {
    if (data == null || data.isEmpty) return const SizedBox.shrink();

    final decoded = decodeHtml(data);

    return MarkdownBody(
      data: decoded,
      selectable: selectable,
      styleSheet: styleSheet ?? _baseStyleSheet(context, style: style),
      onTapLink: (text, href, title) async {
        if (href != null && await canLaunchUrl(Uri.parse(href))) {
          await launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
        }
      },
      builders: {
        'u': _UnderlineBuilder(),
        'mark': _MarkBuilder(),
        'sub': _SubBuilder(),
        'sup': _SupBuilder(),
        'del': _StrikethroughBuilder(), // ~~text~~ + highlight
        'input': _TaskListBuilder(),
        '==': _HighlightBuilder(), // ==text==
      },
    );
  }

  static Widget selectableMarkdownText(BuildContext context, String? data,
      {TextStyle? style, MarkdownStyleSheet? styleSheet}) {
    return markdownText(context, data, style: style, styleSheet: styleSheet, selectable: true);
  }
}

// ===== Custom Builders =====

class _UnderlineBuilder extends MarkdownElementBuilder {
  @override
  Widget visitText(text, TextStyle? preferredStyle) {
    return Text(text.text, style: preferredStyle?.copyWith(decoration: TextDecoration.underline));
  }
}

class _MarkBuilder extends MarkdownElementBuilder {
  @override
  Widget visitText(text, TextStyle? preferredStyle) {
    return Container(
      color: Colors.yellow[300],
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      child: Text(text.text, style: preferredStyle),
    );
  }
}

class _HighlightBuilder extends MarkdownElementBuilder {
  @override
  Widget visitText(text, TextStyle? preferredStyle) {
    return Container(
      color: Colors.yellow[300],
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      child: Text(text.text, style: preferredStyle),
    );
  }
}

class _SubBuilder extends MarkdownElementBuilder {
  @override
  Widget visitText(text, TextStyle? preferredStyle) {
    return Transform.translate(
      offset: const Offset(0, 4),
      child: Text(
        text.text,
        style: (preferredStyle ?? const TextStyle()).copyWith(fontSize: (preferredStyle?.fontSize ?? 14) * 0.8),
      ),
    );
  }
}

class _SupBuilder extends MarkdownElementBuilder {
  @override
  Widget visitText(text, TextStyle? preferredStyle) {
    return Transform.translate(
      offset: const Offset(0, -4),
      child: Text(
        text.text,
        style: (preferredStyle ?? const TextStyle()).copyWith(fontSize: (preferredStyle?.fontSize ?? 14) * 0.8),
      ),
    );
  }
}

class _StrikethroughBuilder extends MarkdownElementBuilder {
  final RegExp highlightReg = RegExp(r'==(.+?)==');

  @override
  Widget visitText(text, TextStyle? preferredStyle) {
    final content = text.text;

    // Nếu có highlight bên trong ~~ ~~ thì chia TextSpan
    final matches = highlightReg.allMatches(content).toList();
    if (matches.isEmpty) {
      return Text(content, style: preferredStyle?.copyWith(decoration: TextDecoration.lineThrough));
    }

    List<InlineSpan> spans = [];
    int lastIndex = 0;

    for (final m in matches) {
      if (m.start > lastIndex) {
        spans.add(TextSpan(
            text: content.substring(lastIndex, m.start),
            style: preferredStyle?.copyWith(decoration: TextDecoration.lineThrough)));
      }
      spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: Container(
            color: Colors.yellow[300],
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
            child: Text(m.group(1)!,
                style: preferredStyle?.copyWith(decoration: TextDecoration.lineThrough)),
          )));
      lastIndex = m.end;
    }

    if (lastIndex < content.length) {
      spans.add(TextSpan(
          text: content.substring(lastIndex),
          style: preferredStyle?.copyWith(decoration: TextDecoration.lineThrough)));
    }

    return RichText(text: TextSpan(children: spans));
  }
}

class _TaskListBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(element, TextStyle? preferredStyle) {
    final isChecked = element.attributes['checked'] == 'true';
    final textContent = element.textContent ?? '';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(value: isChecked, onChanged: null),
        Expanded(child: Text(textContent, style: preferredStyle)),
      ],
    );
  }
}
