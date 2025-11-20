import 'package:flutter/material.dart';
import '../../../../../../core/utils/render_utils.dart';

class PostContent extends StatelessWidget {
  final String? contentText;

  const PostContent({super.key, this.contentText});

  @override
  Widget build(BuildContext context) {
    if (contentText == null || contentText!.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RenderUtils.selectableMarkdownText(context, contentText),
    );
  }
}
