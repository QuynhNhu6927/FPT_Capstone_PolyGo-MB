import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../routes/app_routes.dart';
import '../my_post_content.dart';

class FriendSocialSection extends StatelessWidget {
  const FriendSocialSection({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth < 500
        ? screenWidth * 0.9
        : screenWidth < 900
        ? screenWidth * 0.75
        : screenWidth < 1400
        ? screenWidth * 0.7
        : 900.0;

    // Dynamic icon & font size
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
      borderRadius: BorderRadius.circular(sw(context, 16)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );

    Widget _buildSection(
        {required IconData icon,
          required String label,
          required Color iconColor,
          required VoidCallback onTap}) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: sectionDecoration,
            padding: EdgeInsets.symmetric(
              vertical: sh(context, 20),
              horizontal: sw(context, 12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: iconSize, color: iconColor),
                SizedBox(height: sh(context, 8)),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: fontSize,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),
        ),
      );
    }

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: containerWidth,
        padding: EdgeInsets.symmetric(vertical: sh(context, 12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSection(
              icon: Icons.people_alt_rounded,
              label: loc.translate("friends"),
              iconColor: Colors.blueAccent.shade400,
              onTap: () => Navigator.pushNamed(context, AppRoutes.friends),
            ),
            SizedBox(width: sw(context, 12)),
            _buildSection(
              icon: Icons.article_rounded,
              label: loc.translate("posts"),
              iconColor: Colors.orangeAccent.shade200,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyPostContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
