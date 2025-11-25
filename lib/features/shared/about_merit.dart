import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/localization/app_localizations.dart';

class AboutMeritDialog extends StatelessWidget {
  final int merit;
  const AboutMeritDialog({super.key, required this.merit});

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

    // Xác định màu, nhãn mức trust và chú thích theo mốc
    LinearGradient bgGradient;
    Color iconColor;
    String trustLabel;
    String noteLabel;
    if (merit >= 70) {
      bgGradient = const LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      iconColor = Colors.green.shade700;
      trustLabel = loc.translate("very_trusted");
      noteLabel = loc.translate("merit_range_high");
    } else if (merit >= 51) {
      bgGradient = const LinearGradient(
        colors: [Color(0xFFFFC107), Color(0xFFFFE082)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      iconColor = Colors.orange.shade700;
      trustLabel = loc.translate("warned");
      noteLabel = loc.translate("merit_range_mid");
    } else {
      bgGradient = const LinearGradient(
        colors: [Color(0xFFE53935), Color(0xFFEF9A9A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      iconColor = Colors.red.shade700;
      trustLabel = loc.translate("not_trusted");
      noteLabel = loc.translate("merit_range_low");
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
                // Row Icon + TRUST SCORE
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon vuông bo góc
                    Container(
                      width: sw(context, 60),
                      height: sw(context, 60),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(sw(context, 12)),
                      ),
                      child: Icon(
                        Icons.verified_user,
                        size: sw(context, 36),
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: sw(context, 16)),

                    // Column TRUST SCORE + mức độ
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.translate("TRUST_SCORE"),
                          style: t.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: st(context, 20),
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: sh(context, 4)),
                        Text(
                          trustLabel,
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

                // Điểm hiện tại / 100, căn trái
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "$merit",
                        style: t.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: st(context, 32),
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: " / 100",
                        style: t.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: st(context, 20),
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: sh(context, 16)),

                // Chú thích tùy mức điểm
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
