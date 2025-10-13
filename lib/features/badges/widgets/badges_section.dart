import 'dart:math'; // thêm dòng này để random hình fallback
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/api/api_client.dart';
import '../../../../data/models/badges/badge_model.dart';
import '../../../../data/repositories/badge_repository.dart';
import '../../../../data/services/badge_service.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/localization/app_localizations.dart'; // thêm

class BadgesSection extends StatefulWidget {
  const BadgesSection({super.key});

  @override
  State<BadgesSection> createState() => _BadgesSectionState();
}

class _BadgesSectionState extends State<BadgesSection> {
  List<BadgeModel> _badges = [];
  bool _loading = true;

  final List<String> fallbackImages = [
    "https://img.icons8.com/color/96/trophy.png",
    "https://img.icons8.com/color/96/medal.png",
    "https://img.icons8.com/color/96/star-medal.png",
    "https://img.icons8.com/color/96/award.png",
    "https://img.icons8.com/color/96/championship-belt.png",
    "https://img.icons8.com/color/96/prize.png",
  ];

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
      return;
    }

    try {
      final repo = BadgeRepository(BadgeService(ApiClient()));
      final badges = await repo.getMyBadges(token, lang: 'en');

      if (!mounted) return;
      setState(() {
        _badges = badges;
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
    final loc = AppLocalizations.of(context); // thêm
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth < 500
        ? screenWidth * 0.9
        : screenWidth < 900
        ? screenWidth * 0.75
        : screenWidth < 1400
        ? screenWidth * 0.6
        : 900.0;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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

    final hasBadges = _badges.isNotEmpty;

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: containerWidth,
        padding: EdgeInsets.symmetric(
          horizontal: sw(context, 24),
          vertical: sh(context, 12),
        ),
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
        child: SizedBox(
          height: sw(context, 100) + sh(context, 20),
          child: Row(
            children: [
              Expanded(
                child: hasBadges
                    ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _badges.length,
                  itemBuilder: (context, index) {
                    final badge = _badges[index];
                    final imageUrl = badge.iconUrl.isNotEmpty
                        ? badge.iconUrl
                        : fallbackImages[index % fallbackImages.length];

                    return Padding(
                      padding: EdgeInsets.only(right: sw(context, 12)),
                      child: GestureDetector(
                        onTap: () => _showBadgeDetail(context, badge, imageUrl),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius:
                              BorderRadius.circular(sw(context, 12)),
                              child: Image.network(
                                imageUrl,
                                width: sw(context, 80),
                                height: sw(context, 80),
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                    Container(
                                      width: sw(context, 80),
                                      height: sw(context, 80),
                                      color: Colors.grey[300],
                                      child: Icon(
                                        Icons.shield,
                                        size: sw(context, 40),
                                        color: Colors.grey[600],
                                      ),
                                    ),
                              ),
                            ),
                            SizedBox(height: sh(context, 4)),
                            Text(
                              badge.name,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: st(context, 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
                    : Center(
                  child: Text(
                    loc.translate("no_badges_yet") ?? "Bạn chưa đạt thành tựu nào.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 12),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.allBadges);
                  },
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 28,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBadgeDetail(BuildContext context, BadgeModel badge, String imageUrl) {
    final loc = AppLocalizations.of(context); // thêm
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: sw(context, 40)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sw(context, 16)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: sw(context, 24),
            vertical: sh(context, 12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                badge.name,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: sh(context, 16)),
              ClipRRect(
                borderRadius: BorderRadius.circular(sw(context, 12)),
                child: Image.network(
                  imageUrl,
                  width: sw(context, 120),
                  height: sw(context, 120),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: sw(context, 120),
                    height: sw(context, 120),
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.shield,
                      size: sw(context, 60),
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
              SizedBox(height: sh(context, 12)),
              Text(
                badge.description.isNotEmpty
                    ? badge.description
                    : loc.translate("no_description") ?? "No description available.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: sh(context, 8)),
              Text(
                "${loc.translate("received_on") ?? "Received"}: ${badge.createdAt.split('T').first}",
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
