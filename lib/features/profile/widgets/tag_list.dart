import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';

class TagListWidget extends StatelessWidget {
  final List<String> tags;
  final Color? color;

  const TagListWidget({
    super.key,
    required this.tags,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultColor =
        color ?? (isDark ? Colors.grey[800]! : const Color(0xFFF3F4F6));

    return SizedBox(
      height: sh(context, 25),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tags.length,
        separatorBuilder: (_, __) => SizedBox(width: sw(context, 8)),
        itemBuilder: (context, i) =>
            TagItem(text: tags[i], color: defaultColor),
      ),
    );
  }
}

class TagItem extends StatelessWidget {
  final String text;
  final Color color;

  const TagItem({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw(context, 12),
        vertical: sh(context, 4),
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(sw(context, 20)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black,
        ),
      ),
    );
  }
}
