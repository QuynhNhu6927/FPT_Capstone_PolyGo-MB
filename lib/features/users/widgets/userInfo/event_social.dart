import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../routes/app_routes.dart';
import '../event/user_event_content.dart';
import '../user_post_content.dart';

class EventSocialSection extends StatelessWidget {
  final String? userId;

  const EventSocialSection({
    super.key,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    final iconSize = screenWidth < 500
        ? 40.0
        : screenWidth < 900
        ? 50.0
        : 60.0;

    final fontSize = screenWidth < 500
        ? 14.0
        : screenWidth < 900
        ? 16.0
        : 18.0;

    final sectionDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
            : [Colors.white, Colors.white],
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );

    Widget buildSection({
      required IconData icon,
      required String label,
      required Color iconColor,
      required VoidCallback onTap,
    }) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            decoration: sectionDecoration,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: iconSize, color: iconColor),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: sh(context, 12), horizontal: sw(context, 12),),
      child: Row(
        children: [
          buildSection(
            icon: Icons.event,
            label: loc.translate("Events"),
            iconColor: Colors.blueAccent.shade400,
            onTap: () {
              if (userId == null) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HostedEventsPage(userId: userId!),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          buildSection(
            icon: Icons.article_rounded,
            label: loc.translate("posts"),
            iconColor: Colors.orangeAccent.shade200,
            onTap: () {
              if (userId == null) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserPostContent(userId: userId!),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
