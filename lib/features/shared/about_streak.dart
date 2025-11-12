import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/localization/app_localizations.dart';

class AboutStreakDialog extends StatelessWidget {
  const AboutStreakDialog({super.key});

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

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: containerWidth),
          child: Container(
            padding: EdgeInsets.all(sw(context, 24)),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(sw(context, 16)),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x11000000),
                    blurRadius: 20,
                    offset: Offset(0, 8)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(sw(context, 12)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(sw(context, 12)),
                  ),
                  child: Icon(Icons.local_fire_department_rounded,
                      size: sw(context, 40), color: Colors.redAccent),
                ),
                SizedBox(height: sh(context, 20)),

                Text(
                  loc.translate("about_streak_title") ?? "Chuỗi đăng nhập vào PolyGo!",
                  textAlign: TextAlign.center,
                  style: t.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold, fontSize: st(context, 24)),
                ),
                SizedBox(height: sh(context, 16)),

                Text(
                  "Hãy ghé thăm PolyGo mỗi ngày để duy trì chuỗi của bạn và đạt được danh hiệu riêng!",
                  textAlign: TextAlign.center,
                  style: t.bodyLarge?.copyWith(height: 1.5),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
        ),
      ),
    );
  }
}
