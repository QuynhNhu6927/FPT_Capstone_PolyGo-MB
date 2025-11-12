import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../routes/app_routes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../../core/localization/app_localizations.dart';

class AboutPlusDialog extends StatelessWidget {
  const AboutPlusDialog({super.key});

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
        padding: EdgeInsets.only(
          top: 40,
          bottom: MediaQuery.of(context).viewInsets.bottom + 40,
          left: sw(context, 24),
          right: sw(context, 24),
        ),
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
                    color: const Color(0xFFFFF4E5),
                    borderRadius: BorderRadius.circular(sw(context, 12)),
                  ),
                  child: Icon(Icons.star_rounded,
                      size: sw(context, 40), color: Colors.amber[700]),
                ),
                SizedBox(height: sh(context, 20)),

                Text(
                  loc.translate("about_plus_title") ??
                      "Thành viên Plus của PolyGo",
                  textAlign: TextAlign.center,
                  style: t.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold, fontSize: st(context, 24)),
                ),
                SizedBox(height: sh(context, 16)),

                Text(
                  "Nhãn dành riêng cho thành viên Plus!",
                  textAlign: TextAlign.center,
                  style: t.bodyLarge?.copyWith(height: 1.5),
                ),
                SizedBox(height: sh(context, 32)),

                AppButton(
                  text: loc.translate("register_now") ?? "Đăng ký ngay",
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.shop);
                  },
                  size: ButtonSize.lg,
                  variant: ButtonVariant.primary,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
        ),
      ),
    );
  }
}
