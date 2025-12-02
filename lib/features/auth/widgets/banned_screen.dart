import 'package:flutter/material.dart';
import '../../../../core/theme/size_config.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../core/utils/responsive.dart';
import '../../shared/system_report_dialog.dart';

class BannedScreen extends StatelessWidget {
  const BannedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    final isDark = theme.brightness == Brightness.dark;
    final Gradient cardBackground = isDark
        ? const LinearGradient(
      colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(colors: [Colors.white, Colors.white]);

    final containerWidth = screenWidth < 500
        ? screenWidth * 0.9
        : screenWidth < 800
        ? 450.0
        : 500.0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      backgroundColor: Colors.transparent,
      child: Container(
        width: containerWidth,
        padding: EdgeInsets.all(sw(context, 24)),
        decoration: BoxDecoration(
          gradient: cardBackground,
          color: theme.cardColor,
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
          children: [
            const Icon(
              Icons.block,
              color: Colors.red,
              size: 80,
            ),
            SizedBox(height: sh(context, 20)),
            Text(
              "Tài khoản của bạn đã bị khóa",
              textAlign: TextAlign.center,
              style: t.titleMedium?.copyWith(
                fontSize: st(context, 20),
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: sh(context, 10)),
            Text(
              "Vui lòng liên hệ hỗ trợ nếu bạn cho rằng đây là nhầm lẫn.",
              textAlign: TextAlign.center,
              style: t.bodyMedium?.copyWith(
                fontSize: st(context, 16),
                color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54,
              ),
            ),
            SizedBox(height: sh(context, 20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppButton(
                  text: "Support",
                  onPressed: () {
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (_) => const SystemReportDialog(),
                    );
                  },
                  size: ButtonSize.sm,
                  variant: ButtonVariant.outline,
                ),
                SizedBox(width: sw(context, 16)),
                AppButton(
                  text: "Understand",
                  onPressed: () => Navigator.of(context).pop(),
                  size: ButtonSize.sm,
                  variant: ButtonVariant.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );

  }
}
