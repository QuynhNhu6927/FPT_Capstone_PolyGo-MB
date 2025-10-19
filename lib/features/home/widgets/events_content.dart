import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class EventsContent extends StatelessWidget {
  const EventsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> mockEvents = [
      {
        'title': 'Tech Innovation Summit 2025 — The Future of AI and Robotics',
        'image': 'https://picsum.photos/400/250?random=1',
        'tags': ['Tech', 'AI', 'Networking', 'Hehehe']
      },
      {
        'title': 'Art & Design Fair for Creative Minds',
        'image': 'https://picsum.photos/400/250?random=2',
        'tags': ['Art', 'Exhibition', 'Creative']
      },
      {
        'title': 'Music Festival 2025: Live, Love, and Rock',
        'image': 'https://picsum.photos/400/250?random=3',
        'tags': ['Music', 'Live', 'Outdoor']
      },
      {
        'title': 'Startup Meetup — Founders & Investors Gathering',
        'image': 'https://picsum.photos/400/250?random=4',
        'tags': ['Startup', 'Pitching']
      },
      {
        'title': 'Photography Workshop by Top Creators',
        'image': 'https://picsum.photos/400/250?random=5',
        'tags': ['Photo', 'Workshop']
      },
    ];

    final List<String> selectedFilters = ['Music', 'Tech', 'Free'];

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 600 ? 2 : width < 1000 ? 3 : 4;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Filter Row
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_alt_outlined),
                label: const Text('Filter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor:
                  Theme.of(context).colorScheme.onPrimaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  elevation: 1,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedFilters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final tag = selectedFilters[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tag,
                              style: TextStyle(
                                color:
                                Theme.of(context).colorScheme.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.close_rounded,
                                size: 16, color: Colors.grey),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Expanded(
            child: MasonryGridView.count(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemCount: mockEvents.length,
              itemBuilder: (context, index) {
                final event = mockEvents[index];
                return _buildEventCard(context, event);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Map<String, dynamic> event) {
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

    return Container(
      decoration: BoxDecoration(
        gradient: cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.network(
                event['image'],
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: SizedBox(
                height: 36,
                child: Text(
                  event['title'],
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
            ),
            const SizedBox(height: 10),

            //Tags
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                height: 28,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: event['tags'].length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, tagIndex) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(isDark ? 0.25 : 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        event['tags'][tagIndex],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}
