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
    final isDark = theme.brightness == Brightness.dark;
    final Gradient cardBackground = isDark
        ? const LinearGradient(
            colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(colors: [Colors.white, Colors.white]);

    const levelColor = Color(0xFF2563EB);
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
                                    color: isReached ? levelColor : Colors.grey.shade300,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    lv.order.toString(),
                                    style: t.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isReached ? Colors.white : Colors.black54,
                                    ),
                                  ),
                                ),
                                if (index < _levels.length - 1)
                                  Expanded(
                                    child: Container(
                                      width: 3,
                                      color: isReached ? levelColor : Colors.grey.shade300,
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
                                  gradient: cardBackground,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 8,
                                      color: Colors.black.withOpacity(.06),
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: t.titleMedium!.fontSize! * 2.5,
                                      child: Text(
                                        lv.description,
                                        style: t.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : Colors.black,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "${loc.translate("required_xp")}: ${lv.requiredXP}",
                                      style: t.bodyMedium?.copyWith(
                                        color: isDark ? Colors.grey.shade300 : Colors.grey[700],
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
                                          } else if (currentUserLevel >= lv.order) {
                                            return ShinyButton(
                                              onTap: () async {
                                                final prefs = await SharedPreferences.getInstance();
                                                final token = prefs.getString('token');
                                                if (token == null) return;
                                                try {
                                                  final repo = LevelRepository(LevelService(ApiClient()));
                                                  final res = await repo.claimLevel(token, lv.id.toString());
                                                  if (!mounted) return;
                                                  setState(() {
                                                    _levels[index] = _levels[index].copyWith(isClaimed: true);
                                                  });
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text(res.message)),
                                                  );
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text("Claim failed: $e")),
                                                  );
                                                }
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                                decoration: BoxDecoration(
                                                  color: levelColor,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  loc.translate("claimed"),
                                                  style: t.bodySmall?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ).animate().scale(delay: 200.ms * index, duration: 400.ms).fadeIn(duration: 400.ms),
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
