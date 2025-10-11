import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';

class Badge {
  final String imageUrl;
  final String name;
  final String reason;
  final String date;

  Badge({
    required this.imageUrl,
    required this.name,
    required this.reason,
    required this.date,
  });
}

class BadgesSection extends StatelessWidget {
  BadgesSection({super.key});

  final List<Badge> badges = [
    Badge(
      imageUrl: 'https://img.icons8.com/color/96/000000/trophy.png',
      name: 'Achiever',
      reason: 'Completed 10 lessons',
      date: '2025-10-01',
    ),
    Badge(
      imageUrl: 'https://img.icons8.com/color/96/000000/medal.png',
      name: 'Top Performer',
      reason: 'Top performer of the month',
      date: '2025-09-15',
    ),
    Badge(
      imageUrl: 'https://img.icons8.com/color/96/000000/star.png',
      name: 'Quiz Master',
      reason: 'Perfect quiz score',
      date: '2025-08-20',
    ),
    Badge(
      imageUrl: 'https://img.icons8.com/color/96/000000/fire-element.png',
      name: 'Streak Keeper',
      reason: 'Weekly streak 7 days',
      date: '2025-10-05',
    ),
    Badge(
      imageUrl: 'https://img.icons8.com/color/96/000000/handshake.png',
      name: 'Community Helper',
      reason: 'Supported other learners',
      date: '2025-07-30',
    ),
    Badge(
      imageUrl: 'https://img.icons8.com/color/96/000000/globe.png',
      name: 'Language Lover',
      reason: 'Practiced 5 languages',
      date: '2025-09-01',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final containerWidth = screenWidth < 500
        ? screenWidth * 0.9
        : screenWidth < 900
        ? screenWidth * 0.75
        : screenWidth < 1400
        ? screenWidth * 0.6
        : 900.0;

    return Align(
      alignment: Alignment.topCenter,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;

          return Container(
            width: containerWidth,
            padding: EdgeInsets.symmetric(
              horizontal: sw(context, 24),
              vertical: sh(context, 12),
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : theme.cardColor,
              borderRadius: BorderRadius.circular(sw(context, 16)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: SizedBox(
              height: sw(context, 100),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: badges.length + 1,
                itemBuilder: (context, index) {
                  if (index == badges.length) {
                    // Icon ">" cuối list
                    return Padding(
                      padding: EdgeInsets.only(left: sw(context, 12)),
                      child: Center(
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: sw(context, 32),
                          color: Colors.grey[400],
                        ),
                      ),
                    );
                  }

                  final badge = badges[index];
                  return Padding(
                    padding: EdgeInsets.only(right: sw(context, 12)),
                    child: GestureDetector(
                      onTap: () => _showBadgeDetail(context, badge),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(sw(context, 12)),
                            child: Image.network(
                              badge.imageUrl,
                              width: sw(context, 80),
                              height: sw(context, 80),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    width: sw(context, 80),
                                    height: sw(context, 80),
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.shield,
                                      size: sw(context, 40),
                                      color: Colors.grey[600],
                                    ),
                                  ),
                            ),
                          ),
                          SizedBox(height: sh(context, 4)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showBadgeDetail(BuildContext context, Badge badge) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: sw(context, 40)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sw(context, 16)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: sw(context, 24),
            vertical: sh(context, 12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                badge.name,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: sh(context, 16)),
              ClipRRect(
                borderRadius: BorderRadius.circular(sw(context, 12)),
                child: Image.network(
                  badge.imageUrl,
                  width: sw(context, 120),
                  height: sw(context, 120),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: sw(context, 120),
                    height: sw(context, 120),
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.shield,
                      size: sw(context, 60),
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
              SizedBox(height: sh(context, 12)),
              Text(
                badge.reason,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: sh(context, 8)),
              Text(
                'Received: ${badge.date}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
