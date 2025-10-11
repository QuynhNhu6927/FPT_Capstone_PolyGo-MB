import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/api/api_client.dart';
import '../../../../data/models/auth/me_response.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../routes/app_routes.dart';
import '../../../core/widgets/app_dropdown.dart';
import 'change_password_form.dart';

class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  MeResponse? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
      return;
    }

    try {
      final repo = AuthRepository(AuthService(ApiClient()));
      final user = await repo.me(token);

      if (!mounted) return;
      setState(() {
        _user = user;
        _loading = false;
      });
    } catch (e) {
      await prefs.remove('token');
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final t = theme.textTheme;
    final loc = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final containerWidth = screenWidth < 500
        ? screenWidth * 0.9
        : screenWidth < 900
        ? screenWidth * 0.75
        : screenWidth < 1400
        ? screenWidth * 0.6
        : 900.0;

    if (_loading) {
      return Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: containerWidth,
          padding: EdgeInsets.all(sw(context, 24)),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final name = _user?.name ?? "Unknown User";
    final avatarUrl =
        _user?.avatarUrl ?? "https://randomuser.me/api/portraits/men/32.jpg";
    const rating = "Level 13";
    const spoken = "1402 EXP";
    const introduction =
        "Passionate about learning languages and sharing Vietnamese culture!";

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: containerWidth,
        padding: EdgeInsets.all(sw(context, 24)),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : theme.cardColor,
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
            // --- Avatar & Name ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: sw(context, 36),
                  backgroundImage: NetworkImage(avatarUrl),
                ),
                SizedBox(width: sw(context, 16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: t.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: st(context, 20),
                        ),
                      ),
                      SizedBox(height: sh(context, 4)),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        runSpacing: 2,
                        children: [
                          const Icon(Icons.star,
                              color: Colors.blueAccent, size: 18),
                          Text(rating, style: t.bodyMedium),
                          const Text("•"),
                          Text(spoken, style: t.bodyMedium),
                        ],
                      ),
                    ],
                  ),
                ),
                AppDropdown(
                  icon: Icons.settings,
                  currentValue: "",
                  items: [
                    "Thông tin cá nhân",
                    "Ngôn ngữ và sở thích",
                    "Đổi mật khẩu"
                  ],
                  showIcon: true,
                  showValue: false,
                  showArrow: false,
                  onSelected: (value) {
                    if (!mounted) return;
                    switch (value) {
                      case "Thông tin cá nhân":
                        Navigator.pushNamed(context, AppRoutes.updateProfile);
                        break;
                      case "Ngôn ngữ và sở thích":
                        Navigator.pushNamed(context, AppRoutes.updateProfile);
                        break;
                      case "Đổi mật khẩu":
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierColor: Colors.black54,
                          builder: (_) => Dialog(
                            insetPadding: EdgeInsets.symmetric(horizontal: 24),
                            backgroundColor: Colors.transparent,
                            child: const ChangePasswordForm(),
                          ),
                        );
                        break;
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: sh(context, 20)),

            // --- Giới thiệu ---
            Text(
              loc.translate("introduction"),
              style: t.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: st(context, 16),
              ),
            ),
            SizedBox(height: sh(context, 8)),
            Text(
              introduction,
              style: t.bodyMedium?.copyWith(fontSize: st(context, 14)),
            ),

            SizedBox(height: sh(context, 20)),

            // --- Ngôn ngữ ---
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                int visibleNative = width < 400 ? 1 : width < 700 ? 2 : 3;
                int visibleLearning = width < 400 ? 1 : width < 700 ? 3 : 4;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildLangSectionLimited(
                        context,
                        title: loc.translate("native_language"),
                        tags: ["Vietnamese", "English", "Thai"],
                        color: Colors.green[100]!,
                        visibleCount: visibleNative,
                        partialNext: true,
                      ),
                    ),
                    SizedBox(width: sw(context, 16)),
                    Expanded(
                      child: _buildLangSectionLimited(
                        context,
                        title: loc.translate("learning"),
                        tags: [
                          "French",
                          "Japanese",
                          "Korean",
                          "Chinese",
                          "Spanish",
                          "Italian"
                        ],
                        color: Colors.blue[100]!,
                        visibleCount: visibleLearning,
                        partialNext: true,
                      ),
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: sh(context, 20)),

            // --- Sở thích ---
            Text(
              loc.translate("interests"),
              style: t.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: st(context, 16),
              ),
            ),
            SizedBox(height: sh(context, 8)),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTag(context, "travel"),
                _buildTag(context, "food"),
                _buildTag(context, "movies"),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildTag(BuildContext context, String text, {Color? color}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color backgroundColor = color ??
        (isDark ? Colors.grey[800]! : const Color(0xFFF3F4F6));

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw(context, 12),
        vertical: sh(context, 6),
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(sw(context, 20)),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: st(context, 13),
          color: Colors.black, // luôn màu đen
        ),
      ),
    );
  }

  Widget _buildLangSectionLimited(
      BuildContext context, {
        required String title,
        required List<String> tags,
        required Color color,
        int visibleCount = 1,
        bool partialNext = false,
      }) {
    final t = Theme.of(context).textTheme;
    final tagWidth = 90.0;
    final visibleWidth =
        (tagWidth * visibleCount) + (partialNext ? tagWidth * 0.4 : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: t.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: st(context, 15),
          ),
        ),
        SizedBox(height: sh(context, 8)),
        ClipRect(
          child: SizedBox(
            height: sh(context, 40),
            width: visibleWidth,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tags
                    .map(
                      (e) => Padding(
                    padding: EdgeInsets.only(right: sw(context, 8)),
                    child: _buildTag(context, e, color: color),
                  ),
                )
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
