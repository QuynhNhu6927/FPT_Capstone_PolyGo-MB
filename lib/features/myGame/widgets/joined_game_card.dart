import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../data/models/wordsets/joined_word_set.dart';
import '../../../data/models/wordsets/word_sets_model.dart';
import '../../../routes/app_routes.dart';

class JoinedGameCard extends StatelessWidget {
  final PlayedWordSet wordSet;

  const JoinedGameCard({super.key, required this.wordSet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBackground = isDark
        ? const LinearGradient(
      colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(colors: [Colors.white, Colors.white]);

    final textColor = isDark ? Colors.white70 : Colors.black87;
    final secondaryText = Colors.grey;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- createdAt và averageRating ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('dd MMM yyyy').format(wordSet.lastPlayed),
                    style: TextStyle(color: secondaryText, fontSize: 12),
                  ),
                  Row(
                    children: [
                      Text(
                        '${wordSet.playCount}',
                        style: TextStyle(color: secondaryText, fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.access_time_filled, color: Colors.blue, size: 14),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Title ---
              Text(
                wordSet.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
              ),

              // --- Description ---
              Text(
                wordSet.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: textColor),
              ),
              const SizedBox(height: 16),

              // --- Avatar + Name + Creator ---
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: wordSet.creator.avatarUrl != null &&
                        wordSet.creator.avatarUrl!.isNotEmpty
                        ? NetworkImage(wordSet.creator.avatarUrl!)
                        : null,
                    backgroundColor: Colors.grey[300],
                    child: (wordSet.creator.avatarUrl == null ||
                        wordSet.creator.avatarUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 18, color: Colors.white70)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wordSet.creator.name,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: textColor),
                      ),
                      Text(
                        'Creator',
                        style: TextStyle(fontSize: 12, color: secondaryText),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 16),

              // --- EstimatedTime & AverageTime ---
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Best score: ${wordSet.bestScore}',
                      style: TextStyle(fontSize: 12, color: secondaryText),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Best Time: ${wordSet.bestTime}',
                      style: TextStyle(fontSize: 12, color: secondaryText),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // --- Tags + Star Button ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 28,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 3,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          String label = index == 0
                              ? wordSet.difficulty
                              : wordSet.category;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withOpacity(isDark ? 0.25 : 0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.overview,
                        arguments: {
                          'id': wordSet.id,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'View',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }
}
