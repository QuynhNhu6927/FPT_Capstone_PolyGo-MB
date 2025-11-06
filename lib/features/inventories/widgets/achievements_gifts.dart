import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/responsive.dart';
import '../../../routes/app_routes.dart';

class AchievementsAndGiftsSection extends StatelessWidget {
  const AchievementsAndGiftsSection({super.key});

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
        ? screenWidth * 0.6
        : 900.0;

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

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: containerWidth,
        padding: EdgeInsets.only(top: sh(context, 12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Badges
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.allBadges),
                child: Container(
                  decoration: sectionDecoration,
                  padding: EdgeInsets.symmetric(
                    vertical: sh(context, 24),
                    horizontal: sw(context, 16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        size: sw(context, 60),
                        color: Colors.amber.shade600,
                      ),
                      SizedBox(height: sh(context, 10)),
                      Text(
                        loc.translate("my_badges"),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
              ),
            ),
            SizedBox(width: sw(context, 16)),
            // Gifts
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.allGifts),
                child: Container(
                  decoration: sectionDecoration,
                  padding: EdgeInsets.symmetric(
                    vertical: sh(context, 24),
                    horizontal: sw(context, 16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.card_giftcard_rounded,
                        size: sw(context, 60),
                        color: Colors.pinkAccent.shade200,
                      ),
                      SizedBox(height: sh(context, 10)),
                      Text(
                        loc.translate("my_gifts"),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
