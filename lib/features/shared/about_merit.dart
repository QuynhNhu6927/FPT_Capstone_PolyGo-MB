import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/localization/app_localizations.dart';

class AboutMeritDialog extends StatelessWidget {
  const AboutMeritDialog({super.key});

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
                    color: const Color(0xFFE0F7FA),
                    borderRadius: BorderRadius.circular(sw(context, 12)),
                  ),
                  child: Icon(Icons.verified_user,
                      size: sw(context, 40), color: Colors.teal[700]),
                ),
                SizedBox(height: sh(context, 20)),

                Text(
                  loc.translate("about_merit_title") ?? "Điểm uy tín",
                  textAlign: TextAlign.center,
                  style: t.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold, fontSize: st(context, 24)),
                ),
                SizedBox(height: sh(context, 16)),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "+80 - 100: Bạn là thành viên hoạt động sôi nổi và đáng tin cậy",
                      style: t.bodyLarge?.copyWith(color: Colors.green),
                    ),
                    SizedBox(height: sh(context, 8)),
                    Text(
                      "+40 - 79: Bạn bị cảnh cáo nhiều lần, sẽ bị hạn chế một số chức năng",
                      style: t.bodyLarge?.copyWith(color: Colors.orange),
                    ),
                    SizedBox(height: sh(context, 8)),
                    Text(
                      "+0 - 39: Bạn không đáng tin cậy và sẽ bị cấm trong một thời gian",
                      style: t.bodyLarge?.copyWith(color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
        ),
      ),
    );
  }
}
