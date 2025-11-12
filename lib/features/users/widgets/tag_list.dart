import 'package:flutter/material.dart';

import '../../../core/utils/responsive.dart';

class TagList extends StatelessWidget {
  final List<String> items;
  final List<String>? iconUrls;
  final Color color;

  const TagList({
    super.key,
    required this.items,
    this.iconUrls,
    required this.color,
  });


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultColor =
        color ?? (isDark ? Colors.grey[800]! : const Color(0xFFF3F4F6));

    return SizedBox(
      height: sh(context, 30),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(width: sw(context, 8)),
        itemBuilder: (context, i) => TagItem(
          text: items[i],
          iconUrl:
          iconUrls != null && i < iconUrls!.length ? iconUrls![i] : null,
          color: defaultColor,
        ),
      ),
    );
  }
}

class TagItem extends StatelessWidget {
  final String text;
  final String? iconUrl;
  final Color color;

  const TagItem({
    super.key,
    required this.text,
    this.iconUrl,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw(context, 10),
        vertical: sh(context, 4),
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(sw(context, 20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconUrl != null && iconUrl!.isNotEmpty) ...[
            Image.network(
              iconUrl!,
              width: st(context, 16),
              height: st(context, 16),
              errorBuilder: (_, __, ___) => const Icon(
                Icons.image_not_supported,
                size: 14,
                color: Colors.black54,
              ),
            ),
            SizedBox(width: sw(context, 4)),
          ],
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
