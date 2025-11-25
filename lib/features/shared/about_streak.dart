import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/localization/app_localizations.dart';

class AboutStreakDialog extends StatelessWidget {
  final int streakDay;
  final int longestStreak;

  const AboutStreakDialog({
    super.key,
    required this.streakDay,
    required this.longestStreak,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final loc = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final containerWidth = screenWidth < 500
        ? screenWidth * 0.9
        : screenWidth < 800
        ? 450.0
        : 500.0;

    // Gradient + label
    LinearGradient bgGradient;
    String streakLabel;
    String noteLabel;

    if (streakDay >= 10) {
      bgGradient = const LinearGradient(
        colors: [Color(0xFFFF7043), Color(0xFFFFAB91)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      streakLabel = loc.translate("good_streak") ?? "Good streak";
      noteLabel = loc.translate("keep_going") ?? "Keep going every day!";
    } else if (streakDay >= 3) {
      bgGradient = const LinearGradient(
        colors: [Color(0xFFFFC107), Color(0xFFFFE082)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      streakLabel =
          loc.translate("normal_streak") ?? "Normal streak";
      noteLabel = loc.translate("you_can_reach") ??
          "You can reach a higher streak soon!";
    } else {
      bgGradient = const LinearGradient(
        colors: [Color(0xFFE53935), Color(0xFFEF9A9A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      streakLabel = loc.translate("low_streak") ?? "Low streak";
      noteLabel = loc.translate("try_active") ?? "Try to be active daily!";
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: containerWidth),
          child: Container(
            padding: EdgeInsets.all(sw(context, 24)),
            decoration: BoxDecoration(
              gradient: bgGradient,
              borderRadius: BorderRadius.circular(sw(context, 16)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==== ROW ICON + TITLE ====
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: sw(context, 60),
                      height: sw(context, 60),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(sw(context, 12)),
                      ),
                      child: Icon(
                        Icons.local_fire_department_rounded,
                        size: sw(context, 36),
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: sw(context, 16)),

                    // ==== STREAK TITLE (THÊM SỐ) ====
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$streakDay ${loc.translate('-DAY STREAK')}",
                          style: t.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: st(context, 20),
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: sh(context, 4)),
                        Text(
                          streakLabel,
                          style: t.bodyLarge?.copyWith(
                            fontSize: st(context, 16),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: sh(context, 20)),

                // ==== LONGEST STREAK TEXT ====
                Text(
                  "${loc.translate("longest_streak")} $longestStreak",
                  style: t.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: st(context, 20),
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: sh(context, 16)),

                // ==== DESCRIPTION ====
                Text(
                  noteLabel,
                  textAlign: TextAlign.left,
                  style: t.bodyMedium?.copyWith(
                    fontSize: st(context, 14),
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
        ),
      ),
    );
  }
}
