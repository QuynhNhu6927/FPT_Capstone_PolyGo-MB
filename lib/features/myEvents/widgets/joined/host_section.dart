import 'package:flutter/material.dart';
import '../../../../data/models/events/joined_event_model.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../routes/app_routes.dart';

class HostSection extends StatelessWidget {
  final JoinedEventModel event;
  final Widget? trailing;

  const HostSection({super.key, required this.event, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final secondaryText = isDark ? Colors.grey[400] : Colors.grey[600];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.userProfile,
              arguments: {'id': event.host.id},
            );
          },
          child: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey[300],
            backgroundImage: (event.host.avatarUrl != null &&
                event.host.avatarUrl!.isNotEmpty)
                ? NetworkImage(event.host.avatarUrl!)
                : null,
            child: (event.host.avatarUrl == null ||
                event.host.avatarUrl!.isEmpty)
                ? const Icon(Icons.person, size: 36, color: Colors.white70)
                : null,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.userProfile,
                arguments: {'id': event.host.id},
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.host.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
                Text(
                  'Host',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: secondaryText,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
