import 'package:flutter/material.dart';
import 'package:polygo_mobile/core/localization/app_localizations.dart';
import 'package:polygo_mobile/features/profile/widgets/shiny_avatar.dart';
import 'package:polygo_mobile/routes/app_routes.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/auth/me_response.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../shared/about_merit.dart';
import '../../shared/about_plus.dart';
import '../../shared/about_streak.dart';
import 'change_password_form.dart';

class UserInfoHeader extends StatelessWidget {
  final MeResponse user;
  final VoidCallback onShowFullAvatar;
  final VoidCallback onShowUpdateInfoForm;
  final VoidCallback onLogout;
  final Future<void> Function() onReloadUser;

  const UserInfoHeader({
    super.key,
    required this.user,
    required this.onShowFullAvatar,
    required this.onShowUpdateInfoForm,
    required this.onLogout,
    required this.onReloadUser,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final loc = AppLocalizations.of(context);

    final avatarUrl = user.avatarUrl;
    final name = user.name ?? '';
    final merit = user.merit;
    final experiencePoints = user.experiencePoints;
    final introduction = user.introduction;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------- Header Row ----------
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onShowFullAvatar,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: sw(context, 36),
                    backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                        ? NetworkImage(avatarUrl)
                        : null,
                    backgroundColor: Colors.grey[400],
                    child: (avatarUrl == null || avatarUrl.isEmpty)
                        ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 36,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xff4facfe),
                            Color(0xff00f2fe),
                          ],
                        ),
                      ),
                      child: const Text(
                        "LV 1",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: sw(context, 16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (name.isNotEmpty)
                    Text(
                      name,
                      style: t.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: st(context, 20),
                      ),
                    ),
                    SizedBox(height: sh(context, 4)),
                  if (user.gender != null && user.gender!.isNotEmpty)
                    Wrap(
                      children: [
                        Text(
                          user.gender!,
                          style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            AppDropdown(
              icon: Icons.settings,
              currentValue: "",
              items: [
                loc.translate("personal_info"),
                loc.translate("languages_interests"),
                loc.translate("change_password"),
                loc.translate("logout"),
              ],
              showIcon: true,
              showValue: false,
              showArrow: false,
              onSelected: (value) {
                if (value == loc.translate("personal_info")) {
                  onShowUpdateInfoForm();
                } else if (value == loc.translate("languages_interests")) {
                  Navigator.pushNamed(context, AppRoutes.updateProfile).then((
                    updated,
                  ) {
                    if (updated == true) {
                      onReloadUser();
                    }
                  });
                } else if (value == loc.translate("change_password")) {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    barrierColor: Colors.black54,
                    builder: (_) => Dialog(
                      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
                      backgroundColor: Colors.transparent,
                      child: const ChangePasswordForm(),
                    ),
                  );
                } else if (value == loc.translate("logout")) {
                  onLogout();
                }
              },
            ),
          ],
        ),

        SizedBox(height: sh(context, 16)),
        LayoutBuilder(
          builder: (context, constraints) {
            final maxExp = 1000;
            final currentExp = experiencePoints ?? 0;
            final progress = (currentExp / maxExp).clamp(0.0, 1.0);

            final maxColorWidth = constraints.maxWidth * 0.5;

            return Stack(
              alignment: Alignment.center,
              children: [
                // Nền
                Container(
                  height: 14,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                // Phần màu luôn bắt đầu từ bên trái
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 14,
                    width: maxColorWidth * progress,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xff4facfe),
                          Color(0xff00f2fe),
                        ],
                      ),
                    ),
                  ),
                ),

                // Text EXP
                Text(
                  "$currentExp / $maxExp EXP",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),

        // ---------- Introduction Section ----------
        if (introduction != null && introduction.isNotEmpty) ...[

          SizedBox(height: sh(context, 8)),
          Text(
            introduction,
            style: t.bodyMedium?.copyWith(fontSize: st(context, 14)),
          ),
          SizedBox(height: sh(context, 6)),
        ],

        // ---------- Tags Row ----------
        if ((merit != null && experiencePoints != null) ||
            (user.planType == 'Plus') ||
            (user.streakDays != null && user.streakDays! > 0)) ...[
          SizedBox(height: sh(context, 12)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [

                // Merit tag (NEW UI)
                if (merit != null)
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => const AboutMeritDialog(),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: sw(context, 12),
                        vertical: sh(context, 6),
                      ),
                      margin: EdgeInsets.only(right: sw(context, 8)),
                      decoration: BoxDecoration(
                        gradient: merit >= 70
                        // GREEN 70–100
                            ? const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                            : merit >= 51
                        // YELLOW 51–69
                            ? const LinearGradient(
                          colors: [Color(0xFFFFC107), Color(0xFFFFE082)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                        // RED 0–50
                            : const LinearGradient(
                          colors: [Color(0xFFE53935), Color(0xFFEF9A9A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(sw(context, 16)),
                      ),

                      child: Row(
                        children: [
                          Icon(
                            merit >= 70
                                ? Icons.verified_user
                                : merit >= 51
                                ? Icons.error
                                : Icons.block,
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: sw(context, 4)),
                          Text(
                            "$merit",
                            style: t.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // PlanType tag
                if (user.planType == 'Plus')
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => const AboutPlusDialog(),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(sw(context, 8)),
                      margin: EdgeInsets.only(right: sw(context, 8)),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.orangeAccent,
                            Colors.yellow,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(sw(context, 16)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.stars_sharp,
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: sw(context, 4)),
                          Text(
                            loc.translate("plus_member"),
                            style: t.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // StreakDays tag
                if (user.streakDays != null && user.streakDays! > 0)
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => const AboutStreakDialog(),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: sw(context, 12),
                        vertical: sh(context, 6),
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.red.shade700,
                            Colors.orangeAccent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(sw(context, 16)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: sw(context, 4)),
                          Text(
                            "${user.streakDays} ${loc.translate("days")}",
                            style: t.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],

      ],
    );
  }
}
