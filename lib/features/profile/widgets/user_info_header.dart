import 'package:flutter/material.dart';
import 'package:polygo_mobile/core/localization/app_localizations.dart';
import 'package:polygo_mobile/features/profile/widgets/shiny_avatar.dart';
import 'package:polygo_mobile/routes/app_routes.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/auth/me_response.dart';
import '../../../core/widgets/app_dropdown.dart';
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
    final meritLevel = user.meritLevel;
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
                  user.planType == 'Plus'
                      ? ShinyAvatar(avatarUrl: avatarUrl)
                      : CircleAvatar(
                    radius: sw(context, 36),
                    backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                        ? NetworkImage(avatarUrl)
                        : null,
                    backgroundColor: Colors.grey[400],
                    child: (avatarUrl == null || avatarUrl.isEmpty)
                        ? const Icon(Icons.person, color: Colors.white, size: 36)
                        : null,
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
                  if (meritLevel != null && experiencePoints != null)
                    SizedBox(height: sh(context, 4)),
                  if (meritLevel != null && experiencePoints != null)
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        Text("$experiencePoints EXP", style: t.bodyMedium),
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
                  Navigator.pushNamed(context, AppRoutes.updateProfile).then((updated) {
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
            )
          ],
        ),

        // ---------- Introduction Section ----------
        if (introduction != null && introduction.isNotEmpty) ...[
          SizedBox(height: sh(context, 16)),
          Text(
            loc.translate("introduction"),
            style: t.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: st(context, 16),
            ),
          ),
          SizedBox(height: sh(context, 6)),
          Text(
            introduction,
            style: t.bodyMedium?.copyWith(fontSize: st(context, 14)),
          ),
        ],
      ],
    );
  }
}
