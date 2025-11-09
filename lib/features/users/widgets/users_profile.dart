import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:polygo_mobile/features/users/widgets/tag_list.dart';
import 'package:polygo_mobile/features/users/widgets/user_profile_header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../data/services/apis/user_service.dart';
import '../../../../data/models/user/user_by_id_response.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/localization/app_localizations.dart';
import 'friend_button.dart';

class UserProfile extends StatefulWidget {
  final String? userId;

  const UserProfile({super.key, this.userId});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  Locale? _currentLocale;
  bool _loading = true;
  bool _hasError = false;
  UserByIdResponse? user;

  late final UserRepository _userRepo;

  @override
  void initState() {
    super.initState();
    _userRepo = UserRepository(UserService(ApiClient()));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final locale = AppLocalizations.of(context).locale;
    if (_currentLocale == null ||
        _currentLocale!.languageCode != locale.languageCode) {
      _currentLocale = locale;
      _loadUser(lang: locale.languageCode);
    }
  }

  Future<void> _loadUser({String? lang}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || widget.userId == null) {
        setState(() {
          _hasError = true;
          _loading = false;
        });
        return;
      }

      final result =
      await _userRepo.getUserById(token, widget.userId!, lang: lang ?? 'en');

      if (mounted) {
        setState(() {
          user = result;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final t = theme.textTheme;
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
          padding: const EdgeInsets.all(24),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_hasError || user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(loc.translate("failed_to_load_user_profile")),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _hasError = false;
                });
                _loadUser(lang: _currentLocale?.languageCode);
              },
              child: Text(loc.translate("retry")),
            )
          ],
        ),
      );
    }

    final avatarUrl = user!.avatarUrl;
    final friendStatus = user!.friendStatus;
    final name = user!.name ?? "Unnamed";
    final meritLevel = user!.meritLevel;
    final experiencePoints = user!.experiencePoints;
    final introduction = user!.introduction;
    final nativeLangs = (user!.speakingLanguages ?? [])
        .map((e) => e is Map<String, dynamic> ? e['name']?.toString() ?? '' : e.toString())
        .where((name) => name.isNotEmpty)
        .toList();

    final learningLangs = (user!.learningLanguages ?? [])
        .map((e) => e is Map<String, dynamic> ? e['name']?.toString() ?? '' : e.toString())
        .where((name) => name.isNotEmpty)
        .toList();

    final interests = (user!.interests ?? [])
        .map((e) => e is Map<String, dynamic> ? e['name']?.toString() ?? '' : e.toString())
        .where((name) => name.isNotEmpty)
        .toList();

    final bool hasNoData =
        nativeLangs.isEmpty && learningLangs.isEmpty && interests.isEmpty && (introduction == null || introduction.isEmpty);

    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          // ---------------- Header ----------------
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: containerWidth,
              child: UserProfileHeader(user: user!, loc: loc),
            ),
          ),

          const SizedBox(height: 16),

          // ---------------- Info Section ----------------
          Container(
            width: containerWidth,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                if (introduction != null && introduction.isNotEmpty) ...[
                  Text(loc.translate("introduction"),
                      style: t.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(introduction, style: t.bodyMedium),
                  const SizedBox(height: 20),
                ],
                if (!hasNoData) ...[
                  if (nativeLangs.isNotEmpty) ...[
                    Text(loc.translate("native_languages"),
                        style: t.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TagList(items: nativeLangs, color: Colors.green[100]!),
                    const SizedBox(height: 16),
                  ],
                  if (learningLangs.isNotEmpty) ...[
                    Text(loc.translate("learning"),
                        style: t.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TagList(items: learningLangs, color: Colors.blue[100]!),
                    const SizedBox(height: 20),
                  ],
                  if (interests.isNotEmpty) ...[
                    Text(loc.translate("interests"),
                        style: t.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TagList(items: interests, color: const Color(0xFFF3F4F6)),
                  ],
                ] else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    child: Text(
                      loc.translate("no_information_yet"),
                      style: t.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
        ],
      ),
    );
  }
}
