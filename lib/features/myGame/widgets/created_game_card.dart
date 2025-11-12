import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../data/models/wordsets/word_sets_model.dart';
import '../../../routes/app_routes.dart';

class MyGameCard extends StatelessWidget {
  final WordSetModel wordSet;

  const MyGameCard({super.key, required this.wordSet});

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
                    DateFormat('dd MMM yyyy').format(wordSet.createdAt),
                    style: TextStyle(color: secondaryText, fontSize: 12),
                  ),
                  Row(
                    children: [
                      Text(
                        wordSet.averageRating.toStringAsFixed(1),
                        style: TextStyle(color: secondaryText, fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star, color: Colors.amber, size: 14),
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

              // --- EstimatedTime & AverageTime ---
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Est: ${wordSet.estimatedTimeInMinutes} min',
                      style: TextStyle(fontSize: 12, color: secondaryText),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Avg: ${wordSet.averageTimeInSeconds}s',
                      style: TextStyle(fontSize: 12, color: secondaryText),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // --- WordCount & PlayCount ---
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Words: ${wordSet.wordCount}',
                      style: TextStyle(fontSize: 12, color: secondaryText),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Plays: ${wordSet.playCount}',
                      style: TextStyle(fontSize: 12, color: secondaryText),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

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
                              : index == 1
                              ? wordSet.language.name
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
