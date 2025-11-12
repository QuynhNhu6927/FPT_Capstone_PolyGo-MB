import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/badges/badge_model.dart';
import '../../../../data/repositories/badge_repository.dart';
import '../../../../routes/app_routes.dart';
import '../../../data/services/apis/badge_service.dart';

class AllBadges extends StatefulWidget {
  const AllBadges({super.key});

  @override
  State<AllBadges> createState() => _AllBadgesState();
}

class _AllBadgesState extends State<AllBadges> {
  bool _loading = true;
  List<BadgeModel> _badges = [];
  Locale? _currentLocale;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_currentLocale == null ||
        _currentLocale!.languageCode != locale.languageCode) {
      _currentLocale = locale;
      _loadBadges(lang: locale.languageCode);
    }
  }

  Future<void> _loadBadges({String? lang}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
      return;
    }

    try {
      final repo = BadgeRepository(BadgeService(ApiClient()));
      final badges = await repo.getMyBadgesAll(token, lang: lang ?? 'vi');

      if (!mounted) return;
      setState(() {
        badges.sort((a, b) => (b.has ? 1 : 0).compareTo(a.has ? 1 : 0));
        _badges = badges;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate("load_badges_error")),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final crossAxisCount = screenWidth < 600
        ? 2
        : screenWidth < 1000
        ? 3
        : 4;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_badges.isEmpty) {
      return Center(
        child: Text(
          loc.translate("no_badges_found"),
          style: t.bodyMedium,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        final crossAxisCount = screenWidth < 600
            ? 2
            : screenWidth < 1000
            ? 3
            : 4;

        final childAspectRatio = screenWidth < 350
            ? 0.6
            : screenWidth < 450
            ? 0.73
            : screenWidth < 600
            ? 0.9
            : screenWidth < 1000
            ? 1.0
            : 1.0;

        final double iconSize = screenWidth < 600
            ? 80
            : screenWidth < 1000
            ? 90
            : 100;

        final double titleFontSize = screenWidth < 600
            ? 15
            : screenWidth < 1000
            ? 16
            : 17;

        final double descFontSize = screenWidth < 600
            ? 12
            : screenWidth < 1000
            ? 13
            : 14;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: GridView.builder(
            itemCount: _badges.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: childAspectRatio,
            ),
            itemBuilder: (context, index) {
              final badge = _badges[index];
              final hasBadge = badge.has;

              final BoxDecoration decoration = BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
                      : [Colors.white, Colors.white],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              );

              return Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: decoration,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            badge.iconUrl.isNotEmpty
                                ? badge.iconUrl
                                : 'https://img.icons8.com/color/96/medal.png',
                            height: iconSize,
                            width: iconSize,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: iconSize,
                                  width: iconSize,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.shield, size: 40),
                                ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          badge.name,
                          style: t.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: titleFontSize,
                            color: hasBadge
                                ? (isDark ? Colors.white : Colors.black)
                                : (isDark
                                ? Colors.white70
                                : Colors.grey[700]),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          badge.description.isNotEmpty
                              ? badge.description
                              : loc.translate("no_description"),
                          style: t.bodySmall?.copyWith(
                            color: hasBadge
                                ? (isDark
                                ? Colors.white.withOpacity(0.85)
                                : Colors.black87)
                                : (isDark
                                ? Colors.grey[400]
                                : Colors.grey[600]),
                            fontSize: descFontSize,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (hasBadge && badge.createdAt.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "${loc.translate("received_on")}: ${badge.createdAt.split('T').first}",
                              style: t.bodySmall?.copyWith(
                                color: isDark
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!hasBadge)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child:
                          Icon(Icons.lock, color: Colors.white, size: 40),
                        ),
                      ),
                    ),
                ],
              ).animate().fadeIn(duration: 350.ms, delay: (index * 80).ms);
            },
          ),
        );
      },
    );
  }
}
