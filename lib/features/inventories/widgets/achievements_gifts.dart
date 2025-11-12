import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/responsive.dart';
import '../../../core/api/api_client.dart';
import '../../../data/models/badges/badge_model.dart';
import '../../../data/models/gift/gift_me_response.dart';
import '../../../data/repositories/badge_repository.dart';
import '../../../data/repositories/gift_repository.dart';
import '../../../data/services/apis/badge_service.dart';
import '../../../data/services/apis/gift_service.dart';
import '../../../routes/app_routes.dart';

class AchievementsAndGiftsSection extends StatefulWidget {
  const AchievementsAndGiftsSection({super.key});

  @override
  State<AchievementsAndGiftsSection> createState() => _AchievementsAndGiftsSectionState();
}

class _AchievementsAndGiftsSectionState extends State<AchievementsAndGiftsSection> {
  List<GiftMeItem> _myGifts = [];
  bool _loadingGifts = true;
  late final GiftRepository _repo;

  List<BadgeModel> _myBadges = [];
  bool _loadingBadges = true;
  late final BadgeRepository _badgeRepo;

  @override
  void initState() {
    super.initState();
    _repo = GiftRepository(GiftService(ApiClient()));
    _badgeRepo = BadgeRepository(BadgeService(ApiClient()));
    _loadMyGifts();
    _loadMyBadges();
  }

  Future<void> _loadMyGifts() async {
    setState(() => _loadingGifts = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        setState(() => _loadingGifts = false);
        return;
      }

      final res = await _repo.getMyGifts(token: token, pageSize: 30);
      if (!mounted) return;

      setState(() {
        _myGifts = res?.items ?? [];
        _loadingGifts = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingGifts = false);
    }
  }

  Future<void> _loadMyBadges() async {
    setState(() => _loadingBadges = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        setState(() => _loadingBadges = false);
        return;
      }

      final badges = await _badgeRepo.getMyBadges(token);
      if (!mounted) return;

      setState(() {
        _myBadges = badges;
        _loadingBadges = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingBadges = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth < 500
        ? screenWidth * 0.9
        : screenWidth < 900
        ? screenWidth * 0.75
        : screenWidth < 1400
        ? screenWidth * 0.6
        : 900.0;

    final sectionDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
            : [Colors.white, Colors.white],
      ),
      borderRadius: BorderRadius.circular(sw(context, 16)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
    Widget buildHeader(String title, VoidCallback onTap) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: sw(context, 8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            TextButton(
              onPressed: onTap,
              child: Text(
                loc.translate("detail"),
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        ),
      );
    }

    /// === Scroll ngang 1 hàng Gift ===
    Widget buildGiftRow() {
      if (_loadingGifts) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (_myGifts.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            loc.translate("no_gifts_available"),
            style: theme.textTheme.bodyMedium,
          ),
        );
      }

      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: sw(context, 16),
          vertical: sh(context, 8),
        ),
        child: SizedBox(
          height: sw(context, 100) * 0.6, // Chiều cao giảm còn 60%
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _myGifts.length,
            separatorBuilder: (_, __) => SizedBox(width: sw(context, 12)),
            itemBuilder: (context, index) {
              final gift = _myGifts[index];
              final imageUrl = gift.iconUrl.isNotEmpty
                  ? gift.iconUrl
                  : 'https://img.icons8.com/fluency/96/gift.png';

              return ClipRRect(
                borderRadius: BorderRadius.circular(sw(context, 12)),
                child: AspectRatio(
                  aspectRatio: 1, // Vuông
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.card_giftcard,
                        size: sw(context, 40) * 0.6,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms);
            },
          ),
        ),
      );
    }

    /// Widget row hiển thị badge
    Widget buildBadgeRow() {
      if (_loadingBadges) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (_myBadges.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            loc.translate("no_badges_available"),
            style: theme.textTheme.bodyMedium,
          ),
        );
      }

      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: sw(context, 16),
          vertical: sh(context, 8),
        ),
        child: SizedBox(
          height: sw(context, 100) * 0.6,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _myBadges.length,
            separatorBuilder: (_, __) => SizedBox(width: sw(context, 12)),
            itemBuilder: (context, index) {
              final badge = _myBadges[index];
              final imageUrl = badge.iconUrl.isNotEmpty
                  ? badge.iconUrl
                  : 'https://img.icons8.com/fluency/96/medal.png';

              return ClipRRect(
                borderRadius: BorderRadius.circular(sw(context, 12)),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.emoji_events,
                        size: sw(context, 40) * 0.6,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms);
            },
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: containerWidth,
        margin: EdgeInsets.only(top: sh(context, 12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // My Badges section
            Container(
              decoration: sectionDecoration,
              margin: EdgeInsets.only(bottom: sh(context, 12)),
              padding: EdgeInsets.symmetric(vertical: sh(context, 5), horizontal: sh(context, 10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildHeader(
                    loc.translate("my_badges"),
                        () => Navigator.pushNamed(context, AppRoutes.allBadges),
                  ),
                  buildBadgeRow(),
                ],
              ),
            ),
            // My Gifts section
            Container(
              decoration: sectionDecoration,
              padding: EdgeInsets.symmetric(vertical: sh(context, 5), horizontal: sh(context, 10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildHeader(
                    loc.translate("my_gifts"),
                        () => Navigator.pushNamed(context, AppRoutes.allGifts),
                  ),
                  buildGiftRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
