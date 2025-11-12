import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:polygo_mobile/features/profile/widgets/tag_list.dart';
import 'package:polygo_mobile/features/profile/widgets/update_user_info.dart';
import 'package:polygo_mobile/features/profile/widgets/user_info_header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/api/api_client.dart';
import '../../../../data/models/auth/me_response.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../data/services/apis/auth_service.dart';
import '../../../../routes/app_routes.dart';
import '../../../data/models/user/update_userinfo_request.dart';
import '../../../data/repositories/interest_repository.dart';
import '../../../data/repositories/language_repository.dart';
import '../../../data/repositories/media_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/services/apis/interest_service.dart';
import '../../../data/services/apis/language_service.dart';
import '../../../data/services/apis/media_service.dart';
import '../../../data/services/apis/user_service.dart';
import '../../../data/services/signalr/user_presence.dart';
import '../../../main.dart';
import '../../shared/app_error_state.dart';

class UserInfo extends StatefulWidget {
  final VoidCallback? onError;
  final bool isRetrying;

  const UserInfo({
    super.key,
    this.onError,
    this.isRetrying = false,
  });

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  Locale? _currentLocale;
  MeResponse? _user;
  bool _loading = true;
  bool _hasError = false;

  List<String> _learningLangs = [];
  List<String> _learningIcons = [];
  bool _loadingLearning = true;
  List<String> _nativeLangs = [];
  List<String> _nativeIcons = [];
  bool _loadingNative = true;
  List<String> _interests = [];
  List<String> _interestIcons = [];
  bool _loadingInterests = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void didUpdateWidget(covariant UserInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRetrying && !oldWidget.isRetrying) {
      _loadUser();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = InheritedLocale
        .of(context)
        .locale;
    if (_currentLocale == null ||
        _currentLocale!.languageCode != locale.languageCode) {
      _currentLocale = locale;
      if (_user != null) {
        _loadLearningLanguages(lang: locale.languageCode);
        _loadNativeLanguages(lang: locale.languageCode);
        _loadInterests(lang: locale.languageCode);
      }
    }
  }

  Future<void> _loadUser() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      if (!mounted) return;
      setState(() => _hasError = true);
      widget.onError?.call();
      return;
    }

    try {
      final repo = AuthRepository(AuthService(ApiClient()));
      final user = await repo.me(token);

      if (!mounted) return;

      final locale = InheritedLocale
          .of(context)
          .locale;
      _currentLocale = locale;

      setState(() {
        _user = user;
        _loading = false;
      });

      await Future.wait([
        _loadLearningLanguages(lang: locale.languageCode),
        _loadNativeLanguages(lang: locale.languageCode),
        _loadInterests(lang: locale.languageCode),
      ]);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _hasError = true;
      });
      widget.onError?.call();
    }
  }

  Future<void> _loadInterests({String? lang}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    try {
      setState(() => _loadingInterests = true);
      final repo = InterestRepository(InterestService(ApiClient()));
      final interests = await repo.getInterestsMe(
          token, lang: lang ?? _currentLocale?.languageCode ?? 'vi');

      if (!mounted) return;
      setState(() {
        _interests = interests.map((e) => e.name).toList();
        _interestIcons = interests.map((e) => e.iconUrl).toList();
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
      final langs = await repo.getLearningLanguagesMe(
          token, lang: lang ?? _currentLocale?.languageCode ?? 'vi');

      if (!mounted) return;
      setState(() {
        _learningLangs = langs.map((e) => e.name).toList();
        _learningIcons = langs.map((e) => e.iconUrl).toList();
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
      final langs = await repo.getSpeakingLanguagesMe(
          token, lang: lang ?? _currentLocale?.languageCode ?? 'vi');

      if (!mounted) return;
      setState(() {
        _nativeLangs = langs.map((e) => e.name).toList();
        _nativeIcons = langs.map((e) => e.iconUrl).toList();
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
      builder: (_) =>
          Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.zero,
            child: Stack(
              children: [
                if (avatarUrl != null && avatarUrl.isNotEmpty)
                  Center(
                    child: Image.network(
                      avatarUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
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
                Positioned(
                  top: 40,
                  left: 20,
                  child: IconButton(
                    icon: const Icon(
                        Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await UserPresenceManager().stop();
    debugPrint("Hub state after stop: ${UserPresenceManager().service.connection?.state}");
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
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
    } on DioError catch (e) {
      setState(() => _loading = false);

      if (e.response?.statusCode == 413) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.translate("file_too_large_error")),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.translate("upload_failed")),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate("unexpected_error")),
        ),
      );
    }
  }

  void _showUpdateInfoForm() {
    if (_user == null) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (_) =>
          Dialog(
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
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    final bool hasNoData =
        _nativeLangs.isEmpty && _learningLangs.isEmpty && _interests.isEmpty;

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

    if (_hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: AppErrorState(onRetry: _loadUser),
      );
    }

    if (_user == null) return const SizedBox.shrink();

    final introduction = _user?.introduction;

    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          // ----------------- Container 1: Header -----------------
          Container(
            width: containerWidth,
            padding: EdgeInsets.all(sw(context, 24)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
                    : [const Color(0xFFFFFFFF), const Color(0xFFFFFFFF)],
              ),
              borderRadius: BorderRadius.circular(sw(context, 16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: UserInfoHeader(
              user: _user!,
              onShowFullAvatar: () => _showFullAvatar(context),
              onShowUpdateInfoForm: _showUpdateInfoForm,
              onLogout: () => _logout(context),
              onReloadUser: _loadUser,
            ),
          ).animate().fadeIn(duration: 400.ms),

          SizedBox(height: sh(context, 12)),

          // ----------------- Container 2: Info details -----------------
          Container(
            width: containerWidth,
            padding: EdgeInsets.all(sw(context, 24)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
                    : [const Color(0xFFFFFFFF), const Color(0xFFFFFFFF)],
              ),
              borderRadius: BorderRadius.circular(sw(context, 16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Languages + Interests
                if (hasNoData)
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.updateProfile)
                          .then((updated) {
                        if (updated == true) _loadUser();
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: sh(context, 16),
                        horizontal: sw(context, 12),
                      ),
                      child: Text(
                        loc.translate("no_info_yet"),
                        textAlign: TextAlign.left,
                        style: t.bodyMedium?.copyWith(
                          fontSize: st(context, 15),
                          color: theme.colorScheme.outline,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                else
                  ...[
                    if (_nativeLangs.isNotEmpty) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "${loc.translate("native_language")} ",
                            style: t.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: st(context, 15),
                            ),
                          ),
                          SizedBox(width: sh(context, 4)),
                          Expanded(
                            child: TagListWidget(
                                tags: _nativeLangs,
                                iconUrls: _nativeIcons,
                                color: Colors.green[100]),
                          ),
                        ],
                      ),
                      SizedBox(height: sh(context, 12)),
                  ],
                    if (_learningLangs.isNotEmpty) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "${loc.translate("learning")} ",
                            style: t.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: st(context, 16),
                            ),
                          ),
                          SizedBox(width: sh(context, 4)),
                          Expanded(
                            child: TagListWidget(
                              tags: _learningLangs,
                              iconUrls: _learningIcons,
                              color: Colors.blue[100],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sh(context, 12)),
                    ],

                    if (_interests.isNotEmpty) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "${loc.translate("interests")} ",
                            style: t.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: st(context, 16),
                            ),
                          ),
                          SizedBox(width: sh(context, 4)),
                          Expanded(
                            child: TagListWidget(
                              tags: _interests,
                              iconUrls: _interestIcons,
                            )
                          ),
                        ],
                      ),
                    ],
                  ],
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
        ],
      ),
    );
  }
}

extension MeResponseCopy on MeResponse {
  MeResponse copyWith({
    String? avatarUrl,
    String? name,
    String? introduction,
    String? gender,
    int? experiencePoints,
    String? role,
    String? mail,
    int? merit,
    double? balance,
    int? streakDays,
    bool? autoRenewSubscription,
    bool? isNew,
    DateTime? lastLoginAt,
  }) {
    return MeResponse(
      id: id,
      name: name ?? this.name,
      mail: mail ?? this.mail,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      merit: merit ?? this.merit,
      introduction: introduction ?? this.introduction,
      gender: gender ?? this.gender,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      role: role ?? this.role,
      balance: balance ?? this.balance,
      streakDays: streakDays ?? this.streakDays,
      autoRenewSubscription: autoRenewSubscription ?? this.autoRenewSubscription,
      isNew: isNew ?? this.isNew,
      planType: planType ?? this.planType,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
