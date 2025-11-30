import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polygo_mobile/features/profile/widgets/profileHeader/report_list.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../routes/app_routes.dart';
import '../../../auth/widgets/polygo_terms.dart';
import '../../../users/widgets/system_report_dialog.dart';
import 'change_password_form.dart';

class SettingsFullScreenDialog extends StatelessWidget {
  final AppLocalizations loc;
  final bool isDark;
  final VoidCallback onShowUpdateInfoForm;
  final Future<void> Function() onReloadUser;
  final VoidCallback onLogout;

  const SettingsFullScreenDialog({
    super.key,
    required this.loc,
    required this.isDark,
    required this.onShowUpdateInfoForm,
    required this.onReloadUser,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final background = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          title: Text(
            loc.translate("persona"),
            style: TextStyle(color: textColor),
          ),
          iconTheme: IconThemeData(color: textColor),
        ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              // ===== Top items =====
              Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.person, color: textColor),
                    title: Text(
                      loc.translate("personal_info"),
                      style: TextStyle(color: textColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    onTap: () {
                      Navigator.pop(context);
                      onShowUpdateInfoForm();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.language, color: textColor),
                    title: Text(
                      loc.translate("languages_interests"),
                      style: TextStyle(color: textColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.updateProfile)
                          .then((updated) {
                        if (updated == true) onReloadUser();
                      });
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.lock, color: textColor),
                    title: Text(
                      loc.translate("change_password"),
                      style: TextStyle(color: textColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    onTap: () {
                      Navigator.pop(context);
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
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.flag_outlined, color: textColor),
                    title: Text(
                      loc.translate("reported_list"),
                      style: TextStyle(color: textColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MyReportsScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.privacy_tip, color: textColor),
                    title: Text(
                      loc.translate("terms_privacy"),
                      style: TextStyle(color: textColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (_) => const PolyGoTerms(),
                      );
                    },
                  ),

                ],
              ),

              const Spacer(),

              // ===== Bottom items =====
              Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.contact_support_rounded, color: Colors.orange),
                    title: Text(
                      loc.translate("system_support"),
                      style: TextStyle(color: Colors.orange),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => SystemReportDialog(
                          onSubmit: () {},
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: Text(
                      loc.translate("logout"),
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    onTap: () {
                      Navigator.pop(context);
                      onLogout();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
