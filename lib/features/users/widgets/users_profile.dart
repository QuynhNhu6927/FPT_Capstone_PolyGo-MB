import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:polygo_mobile/features/users/widgets/tag_list.dart';
import 'package:polygo_mobile/features/users/widgets/user_profile_header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/services/apis/user_service.dart';
import '../../../../data/models/user/user_by_id_response.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/localization/app_localizations.dart';

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
    final meritLevel = user!.merit;
    final experiencePoints = user!.experiencePoints;
    final introduction = user!.introduction;
    final nativeLangs = (user!.speakingLanguages ?? [])
        .map((e) => e is Map<String, dynamic> ? e['name']?.toString() ?? '' : e.toString())
        .where((name) => name.isNotEmpty)
        .toList();
    final nativeIcons = (user!.learningLanguages ?? [])
        .map((e) => e is Map<String, dynamic> ? e['iconUrl']?.toString() ?? '' : e.toString())
        .where((iconUrl) => iconUrl.isNotEmpty)
        .toList();

    final learningLangs = (user!.learningLanguages ?? [])
        .map((e) => e is Map<String, dynamic> ? e['name']?.toString() ?? '' : e.toString())
        .where((name) => name.isNotEmpty)
        .toList();
    final learningIcons = (user!.learningLanguages ?? [])
        .map((e) => e is Map<String, dynamic> ? e['iconUrl']?.toString() ?? '' : e.toString())
        .where((iconUrl) => iconUrl.isNotEmpty)
        .toList();

    final interests = (user!.interests ?? [])
        .map((e) => e is Map<String, dynamic> ? e['name']?.toString() ?? '' : e.toString())
        .where((name) => name.isNotEmpty)
        .toList();
    final interestsIcons = (user!.interests ?? [])
        .map((e) => e is Map<String, dynamic> ? e['iconUrl']?.toString() ?? '' : e.toString())
        .where((iconUrl) => iconUrl.isNotEmpty)
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
                // Languages + Interests
                if (hasNoData)
                  Container(
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
                    )
                else
                  ...[
                    if (nativeLangs.isNotEmpty) ...[
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
                            child: TagList(
                                items: nativeLangs,
                                iconUrls: nativeIcons,
                                color: Colors.green[100] ?? Colors.green
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sh(context, 12)),
                    ],
                    if (learningLangs.isNotEmpty) ...[
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
                            child: TagList(
                              items: learningLangs,
                              iconUrls: learningIcons,
                              color: Colors.blue[100] ?? Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sh(context, 12)),
                    ],

                    if (interests.isNotEmpty) ...[
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
                              child: TagList(
                                items: interests,
                                iconUrls: interestsIcons,
                                color: Colors.grey[100] ?? Colors.grey,
                              )
                          ),
                        ],
                      ),
                    ],
                  ],
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          // ---------------- Badges & Gifts Section ----------------
          // ---------------- Badges Container ----------------
          if (user!.badges?.isNotEmpty ?? false)
            Container(
              width: containerWidth,
              margin: EdgeInsets.only(top: sh(context, 14)),
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
                  Text(
                    loc.translate("my_badges"),
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 60, // chiều cao badges row
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: user!.badges!.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final badge = user!.badges![index];
                        final imageUrl = (badge is Map<String, dynamic>)
                            ? (badge['iconUrl'] ?? '')
                            : badge.toString();
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: imageUrl.isNotEmpty
                                ? Image.network(imageUrl, fit: BoxFit.cover)
                                : Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.emoji_events, color: Colors.grey),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

// ---------------- Gifts Container ----------------
          if (user!.gifts?.isNotEmpty ?? false)
            Container(
              width: containerWidth,
              margin: EdgeInsets.only(top: sh(context, 14)),
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
                  Text(
                    loc.translate("my_gifts"),
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 60,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: user!.gifts!.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final gift = user!.gifts![index];
                        final imageUrl = (gift is Map<String, dynamic>)
                            ? (gift['iconUrl'] ?? '')
                            : gift.toString();
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: imageUrl.isNotEmpty
                                ? Image.network(imageUrl, fit: BoxFit.cover)
                                : Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.card_giftcard, color: Colors.grey),
                            ),
                          ),
                        );
                      },
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
