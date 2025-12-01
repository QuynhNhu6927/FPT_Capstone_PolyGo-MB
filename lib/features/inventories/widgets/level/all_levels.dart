import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../core/api/api_client.dart';
import '../../../../../../core/localization/app_localizations.dart';
import '../../../../../../data/models/levels/level_item.dart';
import '../../../../../../data/repositories/level_repository.dart';
import '../../../../../data/services/apis/level_service.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/services/apis/auth_service.dart';
import 'level_buttons.dart';

class AllLevels extends StatefulWidget {
  const AllLevels({super.key});

  @override
  State<AllLevels> createState() => _AllLevelsState();
}

class _AllLevelsState extends State<AllLevels> {
  bool _loading = true;
  List<LevelItem> _levels = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = AppLocalizations.of(context);
      _loadLevels(lang: loc.locale.languageCode);
    });
  }

  Future<void> _loadLevels({String? lang}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    try {
      final repo = LevelRepository(LevelService(ApiClient()));
      final list = await repo.getLevels(
        token,
        lang: lang ?? 'en',
        pageNumber: -1,
        pageSize: -1,
      );

      if (!mounted) return;

      setState(() {
        list.sort((a, b) => a.order.compareTo(b.order));
        _levels = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<int> _loadUserLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return 1;

    final repo = AuthRepository(AuthService(ApiClient()));
    final user = await repo.me(token);

    return user.level;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final t = theme.textTheme;

    const levelBlue = Color(0xFF2563EB);
    const levelGreen = Color(0xFF16A34A);
    const grayBorder = Color(0xFF9CA3AF);
    const grayLight = Color(0xFFF3F4F6);
    const grayDarkText = Color(0xFF4B5563);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.translate("levels"),
          style: t.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _levels.isEmpty
            ? Center(
                child: Text(
                  loc.translate("no_levels_found"),
                  style: t.bodyMedium,
                ),
              )
            : FutureBuilder(
                future: _loadUserLevel(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final currentUserLevel = snapshot.data as int;

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
                    itemCount: _levels.length,
                    itemBuilder: (context, index) {
                      final lv = _levels[index];
                      final claimed = lv.isClaimed;
                      final isReached = lv.order <= currentUserLevel;

                      // Xác định màu sắc UI
                      Color borderColor;
                      Color bgColor;
                      Color titleColor;

                      if (isReached && !claimed) {
                        borderColor = levelBlue;
                        bgColor = levelBlue.withOpacity(0.1);
                        titleColor = levelBlue;
                      } else if (claimed) {
                        borderColor = levelGreen;
                        bgColor = levelGreen.withOpacity(0.1);
                        titleColor = levelGreen;
                      } else {
                        borderColor = grayBorder;
                        bgColor = grayLight;
                        titleColor = grayDarkText;
                      }

                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // LEVEL DOT
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isReached
                                        ? borderColor
                                        : Colors.grey.shade300,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    lv.order.toString(),
                                    style: t.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isReached
                                          ? Colors.white
                                          : Colors.black54,
                                    ),
                                  ),
                                ),
                                if (index < _levels.length - 1)
                                  Expanded(
                                    child: Container(
                                      width: 3,
                                      color: isReached
                                          ? borderColor
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            // Card content với animation
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 30),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: borderColor,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: t.titleMedium!.fontSize! * 2.5,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.card_giftcard,
                                            size: 20,
                                            color: titleColor,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              lv.description,
                                              style: t.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: titleColor,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "${loc.translate("required_xp")}: ${lv.requiredXP}",
                                      style: t.bodyMedium?.copyWith(
                                        color: grayDarkText,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Builder(
                                        builder: (_) {
                                          if (lv.isClaimed) {
                                            return ClaimedButton(
                                              child: Text(
                                                loc.translate("claimed"),
                                                style: t.bodySmall?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            );
                                          } else if (currentUserLevel >=
                                              lv.order) {
                                            return ShinyButton(
                                              onTap: () async {
                                                final prefs =
                                                    await SharedPreferences.getInstance();
                                                final token = prefs.getString(
                                                  'token',
                                                );
                                                if (token == null) return;
                                                try {
                                                  final repo = LevelRepository(
                                                    LevelService(ApiClient()),
                                                  );
                                                  final res = await repo
                                                      .claimLevel(
                                                        token,
                                                        lv.id.toString(),
                                                      );
                                                  if (!mounted) return;
                                                  setState(() {
                                                    _levels[index] =
                                                        _levels[index].copyWith(
                                                          isClaimed: true,
                                                        );
                                                  });
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        res.message,
                                                      ),
                                                    ),
                                                  );
                                                } catch (e) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        "Claim failed: $e",
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child:
                                                  Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 7,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: borderColor,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          loc.translate(
                                                            "claim_now",
                                                          ),
                                                          style: t.bodySmall
                                                              ?.copyWith(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                      )
                                                      .animate()
                                                      .scale(
                                                        delay: 200.ms * index,
                                                        duration: 400.ms,
                                                      )
                                                      .fadeIn(duration: 400.ms),
                                            );
                                          } else {
                                            return LockButton();
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate().slideY(begin: 0.2, delay: 100.ms * index, duration: 400.ms).fadeIn(duration: 400.ms),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
