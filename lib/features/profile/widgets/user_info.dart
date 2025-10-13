import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:polygo_mobile/features/profile/widgets/update_user_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/api/api_client.dart';
import '../../../../data/models/auth/me_response.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../routes/app_routes.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../data/models/user/update_userinfo_request.dart';
import '../../../data/repositories/interest_repository.dart';
import '../../../data/repositories/language_repository.dart';
import '../../../data/repositories/media_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/services/interest_service.dart';
import '../../../data/services/language_service.dart';
import '../../../data/services/media_service.dart';
import '../../../data/services/user_service.dart';
import '../../../main.dart';
import 'change_password_form.dart';

class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  Locale? _currentLocale;
  MeResponse? _user;
  bool _loading = true;
  List<String> _learningLangs = [];
  bool _loadingLearning = true;
  List<String> _nativeLangs = [];
  bool _loadingNative = true;
  List<String> _interests = [];
  bool _loadingInterests = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = InheritedLocale.of(context).locale;
    if (_currentLocale == null || _currentLocale!.languageCode != locale.languageCode) {
      _currentLocale = locale;
      // chỉ reload nếu user đã load
      if (_user != null) {
        _loadLearningLanguages(lang: locale.languageCode);
        _loadNativeLanguages(lang: locale.languageCode);
        _loadInterests(lang: locale.languageCode);
      }
    }
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

      final locale = InheritedLocale.of(context).locale;
      _currentLocale = locale;

      setState(() {
        _user = user;
        _loading = false;
      });

      // load ngay từ lần đầu với locale
      await Future.wait([
        _loadLearningLanguages(lang: locale.languageCode),
        _loadNativeLanguages(lang: locale.languageCode),
        _loadInterests(lang: locale.languageCode),
      ]);
    } catch (e) {
      await prefs.remove('token');
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
    }
  }

  Future<void> _loadInterests({String? lang}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    try {
      setState(() => _loadingInterests = true);
      final repo = InterestRepository(InterestService(ApiClient()));
      final interests = await repo.getInterestsMe(token, lang: lang ?? _currentLocale?.languageCode ?? 'vi');

      if (!mounted) return;
      setState(() {
        _interests = interests.map((e) => e.name).toList();
        _loadingInterests = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingInterests = false);
    }
  }

  Future<void> _loadLearningLanguages({String? lang}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    try {
      setState(() => _loadingLearning = true);
      final repo = LanguageRepository(LanguageService(ApiClient()));
      final langs = await repo.getLearningLanguagesMe(token, lang: lang ?? _currentLocale?.languageCode ?? 'vi');

      if (!mounted) return;
      setState(() {
        _learningLangs = langs.map((e) => e.name).toList();
        _loadingLearning = false;
      });
    } catch (e) {
      setState(() => _loadingLearning = false);
    }
  }

  Future<void> _loadNativeLanguages({String? lang}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    try {
      setState(() => _loadingNative = true);
      final repo = LanguageRepository(LanguageService(ApiClient()));
      final langs = await repo.getSpeakingLanguagesMe(token, lang: lang ?? _currentLocale?.languageCode ?? 'vi');

      if (!mounted) return;
      setState(() {
        _nativeLangs = langs.map((e) => e.name).toList();
        _loadingNative = false;
      });
    } catch (e) {
      setState(() => _loadingNative = false);
    }
  }

  void _showFullAvatar(BuildContext context) {
    final avatarUrl = _user?.avatarUrl;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            // Hiển thị avatar nếu có và load thành công
            if (avatarUrl != null && avatarUrl.isNotEmpty)
              Center(
                child: Image.network(
                  avatarUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Nếu load ảnh lỗi, không hiển thị gì
                    return const SizedBox.shrink();
                  },
                ),
              ),
            // Nút cập nhật luôn hiển thị
            Positioned(
              top: 40,
              right: 20,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.blue,
                onPressed: () {
                  Navigator.of(context).pop();
                  _updateAvatar();
                },
                child: const Icon(Icons.edit, color: Colors.white),
              ),
            ),
            // Nút đóng
            Positioned(
              top: 40,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;
    final loc = AppLocalizations.of(context);

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final file = File(pickedFile.path);

    try {
      setState(() => _loading = true);

      final mediaRepo = MediaRepository(MediaService(ApiClient()));
      final uploadRes = await mediaRepo.uploadFile(token, file);

      if (uploadRes.data == null || uploadRes.data!.url.isEmpty) return;

      final String avatarUrl = uploadRes.data!.url;

      final userRepo = UserRepository(UserService(ApiClient()));
      final req = UpdateInfoRequest(
        name: _user?.name ?? '',
        introduction: _user?.introduction ?? '',
        gender: _user?.gender ?? 'Female',
        avatarUrl: avatarUrl,
      );

      await userRepo.updateUserInfo(token, req);

      if (!mounted) return;
      setState(() {
        _user = _user?.copyWith(avatarUrl: avatarUrl);
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate("avatar_update_success")),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _showUpdateInfoForm() {
    if (_user == null) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        backgroundColor: Colors.transparent,
        child: UpdateUserInfoForm(
          user: _user!,
          onUpdated: (updatedUser) {
            setState(() => _user = updatedUser);
          },
        ),
      ),
    );
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

    if (_user == null) return const SizedBox.shrink();

    final avatarUrl = _user?.avatarUrl;
    final name = _user?.name ?? '';
    final meritLevel = _user?.meritLevel;
    final experiencePoints = _user?.experiencePoints;
    final introduction = _user?.introduction;

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: containerWidth,
        padding: EdgeInsets.all(sw(context, 24)),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : theme.cardColor,
          borderRadius: BorderRadius.circular(sw(context, 16)),
          boxShadow: const [
            BoxShadow(color: Color(0x11000000), blurRadius: 20, offset: Offset(0, 8))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Avatar & Name ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _showFullAvatar(context),
                  child: CircleAvatar(
                    radius: sw(context, 36),
                    backgroundImage:
                    (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
                    child: (avatarUrl == null || avatarUrl.isEmpty)
                        ? Container(
                      width: sw(context, 72),
                      height: sw(context, 72),
                      color: Colors.grey[400],
                      child: const Icon(Icons.person, size: 36, color: Colors.white),
                    )
                        : null,
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
                          runSpacing: 2,
                          children: [
                            const Icon(Icons.star, color: Colors.blueAccent, size: 18),
                            Text(meritLevel, style: t.bodyMedium),
                            const Text("•"),
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
                  ],
                  showIcon: true,
                  showValue: false,
                  showArrow: false,
                  onSelected: (value) {
                    if (value == loc.translate("personal_info")) {
                      _showUpdateInfoForm();
                    } else if (value == loc.translate("languages_interests")) {
                      Navigator.pushNamed(context, AppRoutes.updateProfile).then((updated) {
                        if (updated == true) {
                          _loadUser();
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
                    }
                  },
                )
              ],
            ),
            SizedBox(height: sh(context, 20)),

            // --- Giới thiệu ---
            if (introduction != null && introduction.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                ],
              ),

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
                      child: _loadingNative
                          ? const Center(child: CircularProgressIndicator())
                          : _buildLangSectionLimited(
                        context,
                        title: loc.translate("native_language"),
                        tags: _nativeLangs,
                        color: Colors.green[100]!,
                        visibleCount: visibleNative,
                        partialNext: true,
                      ),
                    ),
                    SizedBox(width: sw(context, 16)),
                    Expanded(
                      child: _loadingLearning
                          ? const Center(child: CircularProgressIndicator())
                          : _buildLangSectionLimited(
                        context,
                        title: loc.translate("learning"),
                        tags: _learningLangs,
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
            _loadingInterests
                ? const Center(child: CircularProgressIndicator())
                : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _interests
                  .map((e) => _buildTag(context, e))
                  .toList(),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildTag(BuildContext context, String text, {Color? color}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color backgroundColor =
        color ?? (isDark ? Colors.grey[800]! : const Color(0xFFF3F4F6));

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
          color: Colors.black,
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

extension MeResponseCopy on MeResponse {
MeResponse copyWith({String? avatarUrl, String? name, String? introduction, String? gender}) {
  return MeResponse(
    id: id,
    name: name ?? this.name,
    mail: mail,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    meritLevel: meritLevel,
    introduction: introduction ?? this.introduction,
    gender: gender ?? this.gender,
    experiencePoints: experiencePoints,
    role: role,
  );
}
}