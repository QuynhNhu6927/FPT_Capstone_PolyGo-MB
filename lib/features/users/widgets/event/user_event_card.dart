import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/events/user_hosted_event_model.dart';
import '../../../home/widgets/social/postCard/share/shared_event_detail.dart';

class UserEventCard extends StatelessWidget {
  final UserHostedEventModel event;

  const UserEventCard({
    super.key,
    required this.event,
  });

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

    final formattedDate = DateFormat('dd MMM yyyy, HH:mm')
        .format(event.startAt.toLocal());

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return SharedEventDetail(
              sharedEventId: event.id,
            );
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner
              AspectRatio(
                aspectRatio: 16 / 10,
                child: event.bannerUrl.isNotEmpty
                    ? Image.network(
                  event.bannerUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => _fallbackBanner(),
                )
                    : _fallbackBanner(),
              ),

              // Title + time
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 36,
                      child: Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          height: 1.3,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Categories
              if (event.categories.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SizedBox(
                    height: 28,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: event.categories.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final category = event.categories[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withOpacity(isDark ? 0.25 : 0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            category.name,
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

              // Status + participants
              Padding(
                padding:
                const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Row(
                  children: [
                    _buildStatusChip(context, event.status),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  Widget _fallbackBanner() {
    return Container(
      color: Colors.grey[400],
      child: const Center(
        child: Icon(
          Icons.event_note_rounded,
          size: 64,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final color = status == 'Approved'
        ? Colors.blue
        : status == 'Live'
        ? Colors.green
        : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
