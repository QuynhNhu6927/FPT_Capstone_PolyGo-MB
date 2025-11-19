// lib/core/utils/render_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:html_unescape/html_unescape.dart';

class RenderUtils {
  /// Decode HTML entities to normal text
  static String decodeHtml(String? htmlText) {
    if (htmlText == null || htmlText.isEmpty) return '';
    final unescape = HtmlUnescape();
    return unescape.convert(htmlText);
  }

  /// Render markdown text normally
  static Widget markdownText(
      BuildContext context,
      String? data, {
        TextStyle? style,
        MarkdownStyleSheet? styleSheet,
      }) {
    if (data == null || data.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final textColor = style?.color ?? (theme.brightness == Brightness.dark ? Colors.white70 : Colors.black87);

    return MarkdownBody(
      data: decodeHtml(data),
      styleSheet: styleSheet ??
          MarkdownStyleSheet.fromTheme(theme).copyWith(
            p: TextStyle(fontSize: 14, color: textColor),
            h1: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
            h2: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
            h3: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
    );
  }

  /// Render markdown as selectable text
  static Widget selectableMarkdownText(
      BuildContext context,
      String? data, {
        TextStyle? style,
        MarkdownStyleSheet? styleSheet,
      }) {
    if (data == null || data.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final textColor = style?.color ?? (theme.brightness == Brightness.dark ? Colors.white70 : Colors.black87);

    // Decode HTML entities
    final decoded = decodeHtml(data);

    return MarkdownBody(
      data: decoded,
      styleSheet: styleSheet ??
          MarkdownStyleSheet.fromTheme(theme).copyWith(
            p: TextStyle(fontSize: 14, color: textColor),
            h1: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
            h2: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
            h3: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
      selectable: true,
    );
  }
}
