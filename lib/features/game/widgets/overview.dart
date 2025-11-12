// lib/features/wordsets/widgets/overview_widget.dart
import 'package:flutter/material.dart';
import '../widgets/wordset_details.dart';
import '../widgets/leaderboard_widget.dart';
import '../../../core/utils/responsive.dart';

class OverviewWidget extends StatelessWidget {
  final String wordSetId;

  const OverviewWidget({super.key, required this.wordSetId});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final bgColor = isDark ? Colors.black : Colors.white;

        return Container(
          width: double.infinity,
          height: double.infinity,
          color: bgColor,
          child: isWide
              ? Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: WordSetDetails(wordSetId: wordSetId),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 3,
                  child: LeaderboardWidget(wordSetId: wordSetId),
                ),
              ],
            ),
          )
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WordSetDetails(wordSetId: wordSetId),
                  const SizedBox(height: 20),
                  LeaderboardWidget(wordSetId: wordSetId),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
