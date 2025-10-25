import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/badges/badge_model.dart';
import '../../../../data/models/gift/gift_received_response.dart';
import '../../../../data/repositories/badge_repository.dart';
import '../../../../data/repositories/gift_repository.dart';
import '../../../../data/services/badge_service.dart';
import '../../../../data/services/gift_service.dart';
import '../../../../core/utils/responsive.dart';
import '../../../routes/app_routes.dart';
import '../../shared/app_error_state.dart';

class AchievementsAndGiftsSection extends StatefulWidget {
  final VoidCallback? onLoaded;
  final VoidCallback? onError;
  final bool isRetrying;

  const AchievementsAndGiftsSection({
    super.key,
    this.onLoaded,
    this.onError,
    this.isRetrying = false,
  });

  @override
  State<AchievementsAndGiftsSection> createState() =>
      _AchievementsAndGiftsSectionState();
}

class _AchievementsAndGiftsSectionState
    extends State<AchievementsAndGiftsSection> {
  bool _loading = true;
  bool _hasError = false;
  List<BadgeModel> _badges = [];
  List<GiftItem> _gifts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant AchievementsAndGiftsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Khi isRetrying = true → reload
    if (widget.isRetrying && !oldWidget.isRetrying) {
      _loadData();
    }
  }

  bool _isOwnedBadge(BadgeModel b) {
    final dynamic val = b.has;
    if (val == null) return false;
    if (val is bool) return val;
    if (val is int) return val != 0;
    if (val is String) {
      final lower = val.toLowerCase();
      return lower == 'true' || lower == '1';
    }
    return false;
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        // Token mất → hiện lỗi tại chỗ, không logout
        setState(() {
          _loading = false;
          _hasError = true;
        });
        return;
      }

      final badgeRepo = BadgeRepository(BadgeService(ApiClient()));
      final giftRepo = GiftRepository(GiftService(ApiClient()));

      final results = await Future.wait([
        badgeRepo.getMyBadgesAll(token),
        giftRepo.getReceivedGifts(
          token: token,
          pageNumber: 1,
          pageSize: 20,
          lang: 'vi',
        ),
      ]).timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          setState(() {
            _loading = false;
            _hasError = true;
          });
          return [];
        },
      );

      if (!mounted) return;

      final badges = results[0] as List<BadgeModel>;
      final giftsResponse = results[1] as GiftReceivedResponse?;

      setState(() {
        _badges = badges.where(_isOwnedBadge).take(6).toList();
        _gifts = giftsResponse?.items.take(6).toList() ?? [];
        _loading = false;
        _hasError = false;
      });

      widget.onLoaded?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _hasError = true;
      });
      widget.onError?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: AppErrorState(onRetry: _loadData),
      );
    }

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

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: containerWidth,
        padding: EdgeInsets.symmetric(vertical: sh(context, 12)),
        child: Column(
          children: [
            _SectionRow(
              title: loc.translate("my_badges"),
              items: _badges
                  .map(
                    (b) => _ItemCard(
                  image: b.iconUrl,
                  name: b.name,
                ),
              )
                  .toList(),
              onTapViewAll: () =>
                  Navigator.pushNamed(context, AppRoutes.allBadges),
              decoration: sectionDecoration,
              isDark: isDark,
            ),
            SizedBox(height: sh(context, 16)),
            _SectionRow(
              title: loc.translate("my_gifts"),
              items: _gifts
                  .map(
                    (g) => _ItemCard(
                  image: g.giftIconUrl,
                  name: g.giftName,
                ),
              )
                  .toList(),
              onTapViewAll: () =>
                  Navigator.pushNamed(context, AppRoutes.allGifts),
              decoration: sectionDecoration,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionRow extends StatelessWidget {
  final String title;
  final List<_ItemCard> items;
  final VoidCallback onTapViewAll;
  final BoxDecoration decoration;
  final bool isDark;

  const _SectionRow({
    required this.title,
    required this.items,
    required this.onTapViewAll,
    required this.decoration,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: decoration,
      padding: EdgeInsets.all(sw(context, 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: onTapViewAll,
                child: Text(
                  "Xem tất cả",
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.blueAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sh(context, 10)),
          // horizontal scroll list
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: items
                  .map((item) => Padding(
                padding: EdgeInsets.only(right: sw(context, 14)),
                child: item,
              ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final String image;
  final String name;

  const _ItemCard({required this.image, required this.name});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            image.isNotEmpty ? image : 'https://via.placeholder.com/100',
            width: sw(context, 80),
            height: sw(context, 80),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: sw(context, 80),
              height: sw(context, 80),
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported),
            ),
          ),
        ),
        SizedBox(height: sh(context, 8)),
        SizedBox(
          width: sw(context, 90),
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 350.ms);
  }
}
