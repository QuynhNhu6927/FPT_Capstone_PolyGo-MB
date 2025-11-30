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

    // Gradient vàng
    final LinearGradient bgGradient = const LinearGradient(
      colors: [Color(0xFFFFC107), Color(0xFFFFE082)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

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
                // Row Icon + TITLE + DESCRIPTION
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon vuông bo góc, màu trắng
                    Container(
                      width: sw(context, 60),
                      height: sw(context, 60),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(sw(context, 12)),
                      ),
                      child: Icon(
                        Icons.star_rounded,
                        size: sw(context, 36),
                        color: Colors.white, // đổi màu icon
                      ),
                    ),
                    SizedBox(width: sw(context, 16)),

                    // Column tiêu đề + mô tả
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.translate("about_plus_title") ??
                                "Thành viên Plus của PolyGo",
                            style: t.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: st(context, 20),
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: sh(context, 4)),
                          Text(
                            loc.translate("about_plus_description") ??
                                "Nhãn dành riêng cho thành viên Plus!",
                            style: t.bodyLarge?.copyWith(
                              fontSize: st(context, 16),
                              height: 1.5,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: sh(context, 20)),

                // ==== LONGEST STREAK TEXT ====
                Text(
                  loc.translate("about_plus"),
                  style: t.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: st(context, 20),
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: sh(context, 20)),

                // BUTTON custom
                Align(
                  alignment: Alignment.centerLeft, // căn trái
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.shop);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFB8C00), // màu nền cam đậm
                      foregroundColor: Colors.white, // màu chữ
                      padding: EdgeInsets.symmetric(
                        vertical: sh(context, 14),
                        horizontal: sw(context, 24), // thêm padding ngang cho nút
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(sw(context, 12)), // bo góc
                      ),
                      textStyle: TextStyle(
                        fontSize: st(context, 16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text(loc.translate("register_now") ?? "Đăng ký ngay"),
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
