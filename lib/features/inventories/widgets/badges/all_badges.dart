import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/api/api_client.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../data/models/badges/badge_model.dart';
import '../../../../../data/repositories/badge_repository.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../data/services/apis/badge_service.dart';
import 'badge_detail.dart';

class AllBadges extends StatefulWidget {
  final void Function(BadgeModel updatedBadge)? onBadgeClaimed;

  const AllBadges({super.key, this.onBadgeClaimed});

  @override
  State<AllBadges> createState() => _AllBadgesState();
}

class _AllBadgesState extends State<AllBadges> {
  bool _loading = true;
  List<BadgeModel> _badges = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = AppLocalizations.of(context);
      _loadBadges(lang: loc.locale.languageCode);
    });
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
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_badges.isEmpty) {
      return Center(
        child: Text(loc.translate("no_badges_found"), style: t.bodyMedium),
      );
    }

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        title: Text(loc.translate("my_badges")),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
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

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => BadgeDetailDialog(badgeId: badge.id),
                      );
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? [
                                      const Color(0xFF1E1E1E),
                                      const Color(0xFF2C2C2C),
                                    ]
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
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
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
                                        child: const Icon(
                                          Icons.shield,
                                          size: 40,
                                        ),
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
                              const SizedBox(height: 10),
                              if (hasBadge && !badge.isClaimed)
                                ShinyButton(
                                  onTap: () async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    final token = prefs.getString('token');
                                    if (token == null) return;

                                    try {
                                      final repo = BadgeRepository(
                                        BadgeService(ApiClient()),
                                      );
                                      final res = await repo.claimBadge(
                                        token,
                                        badge.id,
                                      );

                                      if (!mounted) return;
                                      setState(() {
                                        _badges[index] = _badges[index]
                                            .copyWith(
                                              isClaimed: true,
                                              claimedAt: DateTime.now()
                                                  .toIso8601String(),
                                            );
                                      });
                                      if (widget.onBadgeClaimed != null) {
                                        widget.onBadgeClaimed!(_badges[index]);
                                      }
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            res?.message ??
                                                loc.translate('claimed'),
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            loc.translate('claimed_error'),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2563EB),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      loc.translate("claimed"),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              else if (hasBadge && badge.isClaimed)
                                // SHOW CLAIMED DATE
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.2)
                                        : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "${loc.translate("claimed_on")}: ${badge.claimedAt.split('T').first}",
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
                          ),
                        ),
                        // LOCK overlay
                        if (!hasBadge && !badge.isClaimed)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.45),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.lock,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ).animate().fadeIn(duration: 350.ms, delay: (index * 80).ms),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class ShinyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const ShinyButton({required this.child, this.onTap, super.key});

  @override
  State<ShinyButton> createState() => _ShinyButtonState();
}

class _ShinyButtonState extends State<ShinyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.6),
                  Colors.white.withOpacity(0.0),
                ],
                stops: const [0.0, 0.5, 1.0],
                begin: Alignment(-1.0 + 2.0 * _controller.value, -0.3),
                end: Alignment(1.0 + 2.0 * _controller.value, 0.3),
              ).createShader(rect);
            },
            blendMode: BlendMode.srcATop,
            child: widget.child,
          );
        },
      ),
    );
  }
}
