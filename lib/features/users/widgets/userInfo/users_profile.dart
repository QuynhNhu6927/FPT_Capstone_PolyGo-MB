import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:polygo_mobile/features/users/widgets/userInfo/tag_list.dart';
import 'package:polygo_mobile/features/users/widgets/userInfo/user_profile_header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../data/repositories/user_repository.dart';
import '../../../../data/services/apis/user_service.dart';
import '../../../../../data/models/user/user_by_id_response.dart';
import '../../../../../core/api/api_client.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../inventories/widgets/badges/badge_detail.dart';

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

      final result = await _userRepo.getUserById(
        token,
        widget.userId!,
        lang: lang ?? 'en',
      );

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

    if (_loading) {
      return Center(child: CircularProgressIndicator());
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
            ),
          ],
        ),
      );
    }

    // ---------------- Data Processing ----------------
    final nativeLangs = (user!.speakingLanguages ?? [])
        .map(
          (e) => e is Map<String, dynamic>
              ? e['name']?.toString() ?? ''
              : e.toString(),
        )
        .where((name) => name.isNotEmpty)
        .toList();
    final nativeIcons = (user!.speakingLanguages ?? [])
        .map(
          (e) => e is Map<String, dynamic>
              ? e['iconUrl']?.toString() ?? ''
              : e.toString(),
        )
        .where((icon) => icon.isNotEmpty)
        .toList();
    final learningLangs = (user!.learningLanguages ?? [])
        .map(
          (e) => e is Map<String, dynamic>
              ? e['name']?.toString() ?? ''
              : e.toString(),
        )
        .where((name) => name.isNotEmpty)
        .toList();
    final learningIcons = (user!.learningLanguages ?? [])
        .map(
          (e) => e is Map<String, dynamic>
              ? e['iconUrl']?.toString() ?? ''
              : e.toString(),
        )
        .where((icon) => icon.isNotEmpty)
        .toList();
    final interests = (user!.interests ?? [])
        .map(
          (e) => e is Map<String, dynamic>
              ? e['name']?.toString() ?? ''
              : e.toString(),
        )
        .where((name) => name.isNotEmpty)
        .toList();
    final interestsIcons = (user!.interests ?? [])
        .map(
          (e) => e is Map<String, dynamic>
              ? e['iconUrl']?.toString() ?? ''
              : e.toString(),
        )
        .where((icon) => icon.isNotEmpty)
        .toList();
    final hasNoData =
        nativeLangs.isEmpty && learningLangs.isEmpty && interests.isEmpty;

    final isWide = screenWidth >= 1024;

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---------------- Header + Info ----------------
            isWide
                ? IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: UserProfileHeader(user: user!, loc: loc),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoSection(
                            context,
                            isDark,
                            t,
                            loc,
                            nativeLangs,
                            nativeIcons,
                            learningLangs,
                            learningIcons,
                            interests,
                            interestsIcons,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      UserProfileHeader(user: user!, loc: loc),
                      const SizedBox(height: 16),
                      _buildInfoSection(
                        context,
                        isDark,
                        t,
                        loc,
                        nativeLangs,
                        nativeIcons,
                        learningLangs,
                        learningIcons,
                        interests,
                        interestsIcons,
                      ),
                    ],
                  ),

            const SizedBox(height: 16),

            // ---------------- Badges + Gifts ----------------
            isWide
                ? IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _buildBadgesSection(
                            context,
                            user!,
                            isDark,
                            t,
                            loc,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildGiftsSection(
                            context,
                            user!,
                            isDark,
                            t,
                            loc,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      _buildBadgesSection(context, user!, isDark, t, loc),
                      const SizedBox(height: 16),
                      _buildGiftsSection(context, user!, isDark, t, loc),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    bool isDark,
    TextTheme t,
    AppLocalizations loc,
    List<String> nativeLangs,
    List<String> nativeIcons,
    List<String> learningLangs,
    List<String> learningIcons,
    List<String> interests,
    List<String> interestsIcons,
  ) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
              : [Colors.white, Colors.white],
        ),
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
          _buildTagRowWithFallback(
            title: loc.translate("native_language"),
            items: nativeLangs,
            icons: nativeIcons,
            color: Colors.green[100]!,
            loc: loc,
          ),
          _buildTagRowWithFallback(
            title: loc.translate("learning"),
            items: learningLangs,
            icons: learningIcons,
            color: Colors.blue[100]!,
            loc: loc,
          ),
          _buildTagRowWithFallback(
            title: loc.translate("interests"),
            items: interests,
            icons: interestsIcons,
            color: Colors.grey[100]!,
            loc: loc,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildTagRowWithFallback({
    required String title,
    required List<String> items,
    required List<String> icons,
    required Color color,
    required AppLocalizations loc,
  }) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          "${loc.translate("no_user_info_yet")} $title",
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      );
    }

    return _buildTagRow(title, items, icons, color);
  }

  Widget _buildTagRow(
    String title,
    List<String> items,
    List<String> icons,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: TagList(items: items, iconUrls: icons, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection(
    BuildContext context,
    UserByIdResponse user,
    bool isDark,
    TextTheme t,
    AppLocalizations loc,
  ) {
    final hasBadges = !(user.badges?.isEmpty ?? true);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
              : [Colors.white, Colors.white],
        ),
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
          if (hasBadges)
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: user.badges!.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final badge = user.badges![index];
                  final imageUrl = (badge is Map<String, dynamic>)
                      ? (badge['iconUrl'] ?? '')
                      : badge.toString();
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      if (badge is Map<String, dynamic> && badge['id'] != null) {
                        showDialog(
                          context: context,
                          builder: (_) => BadgeDetailDialog(badgeId: badge['id']),
                        );
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: imageUrl.isNotEmpty
                            ? Image.network(imageUrl, fit: BoxFit.cover)
                            : Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.emoji_events,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms);
                },
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                loc.translate("no_badges"),
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildGiftsSection(
    BuildContext context,
    UserByIdResponse user,
    bool isDark,
    TextTheme t,
    AppLocalizations loc,
  ) {
    final hasGifts = !(user.gifts?.isEmpty ?? true);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
              : [Colors.white, Colors.white],
        ),
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
          if (hasGifts)
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: user.gifts!.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final gift = user.gifts![index];
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
                              child: const Icon(
                                Icons.card_giftcard,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  );
                },
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                loc.translate("no_gifts"),
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}
