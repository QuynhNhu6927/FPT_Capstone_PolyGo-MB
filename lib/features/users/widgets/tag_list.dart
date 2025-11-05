import 'package:flutter/material.dart';

class TagList extends StatelessWidget {
  final List<String> items;
  final Color color;

  const TagList({
    super.key,
    required this.items,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 25,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => TagItem(text: items[i], color: color),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, color: Colors.black),
      ),
    );
  }
}
