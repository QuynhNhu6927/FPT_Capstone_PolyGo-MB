import 'package:flutter/material.dart';
import 'post_utils.dart';

class ReactionBar extends StatelessWidget {
  final int? selectedReaction;
  final Function(int index) onReactionTap;

  ReactionBar({
    super.key,
    required this.selectedReaction,
    required this.onReactionTap,
  });

  final List<Map<String, dynamic>> _reactions = const [
    {'asset': 'like.png', 'color': Colors.blue},
    {'asset': 'heart.png', 'color': Colors.red},
    {'asset': 'haha.png', 'color': Colors.orange},
    {'asset': 'surprised.png', 'color': Colors.amber},
    {'asset': 'sad.png', 'color': Colors.indigo},
    {'asset': 'angry.png', 'color': Colors.deepOrange},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < _reactions.length; i++)
          GestureDetector(
            onTap: () => onReactionTap(i),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: selectedReaction == i
                    ? _reactions[i]['color'].withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                'assets/${_reactions[i]['asset']}',
                width: 24,
                height: 24,
              ),
            ),
          ),
      ],
    );
  }
}
