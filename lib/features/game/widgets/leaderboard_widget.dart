import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/wordsets/leaderboard_model.dart';
import '../../../data/repositories/wordset_repository.dart';
import '../../../data/services/apis/wordset_service.dart';
import '../../../core/api/api_client.dart';
import '../../../core/utils/responsive.dart';

class LeaderboardWidget extends StatefulWidget {
  final String wordSetId;

  const LeaderboardWidget({super.key, required this.wordSetId});

  @override
  State<LeaderboardWidget> createState() => _LeaderboardWidgetState();
}

class _LeaderboardWidgetState extends State<LeaderboardWidget> {
  late final WordSetRepository _repository;
  late Future<LeaderboardResponse> _futureLeaderboard;

  @override
  void initState() {
    super.initState();
    _repository = WordSetRepository(WordSetService(ApiClient()));
    _futureLeaderboard = _loadLeaderboard();
  }

  Future<LeaderboardResponse> _loadLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return _repository.getLeaderboard(token, wordSetId: widget.wordSetId);
  }

  LinearGradient? _rankGradient(int rank) {
    switch (rank) {
      case 1:
        return const LinearGradient(colors: [Colors.amber, Colors.yellow]);
      case 2:
        return const LinearGradient(colors: [Colors.grey, Colors.white]);
      case 3:
        return const LinearGradient(colors: [Colors.brown, Colors.orange]);
      default:
        return null;
    }
  }

  Color _rankTextColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.orange.shade900;
      case 2:
        return Colors.grey.shade900;
      case 3:
        return Colors.brown.shade900;
      default:
        return Colors.green.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final colorPrimary = theme.colorScheme.primary;

    return FutureBuilder<LeaderboardResponse>(
      future: _futureLeaderboard,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Failed to load leaderboard: ${snapshot.error}'),
          );
        }

        final leaderboard = snapshot.data;
        if (leaderboard == null || leaderboard.items.isEmpty) {
          return Center(
            child: Text(
              "No leaderboard data yet.",
              style: t.bodyMedium?.copyWith(color: Colors.grey),
            ),
          );
        }

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
                  )
                : const LinearGradient(colors: [Colors.white, Colors.white]),
            borderRadius: BorderRadius.circular(sw(context, 16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(sw(context, 16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Leaderboard",
                  style: t.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: st(context, 20),
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: sh(context, 16)),

                ...leaderboard.items.asMap().entries.map((entry) {
                  final item = entry.value;
                  final player = item.player;
                  final rankGradient = _rankGradient(item.rank);
                  final rankTextColor = _rankTextColor(item.rank);

                  return Padding(
                    padding: EdgeInsets.only(bottom: sh(context, 12)),
                    child: Container(
                      padding: EdgeInsets.all(sw(context, 12)),
                      decoration: BoxDecoration(
                        gradient: isDark
                            ? const LinearGradient(
                                colors: [Color(0xFF2C2C2C), Color(0xFF3A3A3A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : LinearGradient(
                                colors: [
                                  Colors.grey.shade100,
                                  Colors.grey.shade100,
                                ],
                              ),
                        borderRadius: BorderRadius.circular(sw(context, 12)),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isSmallScreen = constraints.maxWidth < 350;

                          return isSmallScreen
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Hàng đầu: rank + avatar + name
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Rank icon + number
                                        Container(
                                          width: sw(context, 36),
                                          height: sw(context, 36),
                                          alignment: Alignment.center,
                                          child: item.rank <= 3
                                              ? Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.brightness_5_sharp,
                                                      size: 32,
                                                      color: item.rank == 1
                                                          ? Colors.amber
                                                          : item.rank == 2
                                                          ? Colors.grey
                                                          : Colors.brown,
                                                    ),
                                                    Text(
                                                      "${item.rank}",
                                                      style: t.titleMedium
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                item.rank == 1
                                                                ? Colors.amber
                                                                : item.rank == 2
                                                                ? Colors.grey
                                                                : Colors.brown,
                                                            fontSize: st(
                                                              context,
                                                              16,
                                                            ),
                                                          ),
                                                    ),
                                                  ],
                                                )
                                              : Text(
                                                  "${item.rank}",
                                                  style: t.titleLarge?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        Colors.green.shade400,
                                                    fontSize: st(context, 20),
                                                  ),
                                                ),
                                        ),
                                        SizedBox(width: sw(context, 10)),

                                        // Avatar + name + date
                                        Expanded(
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: sw(context, 18),
                                                backgroundImage:
                                                    (player.avatarUrl != null &&
                                                        player
                                                            .avatarUrl!
                                                            .isNotEmpty)
                                                    ? NetworkImage(
                                                        player.avatarUrl!,
                                                      )
                                                    : null,
                                                backgroundColor:
                                                    Colors.grey.shade400,
                                                child:
                                                    (player.avatarUrl == null ||
                                                        player
                                                            .avatarUrl!
                                                            .isEmpty)
                                                    ? const Icon(
                                                        Icons.person,
                                                        color: Colors.white,
                                                        size: 20,
                                                      )
                                                    : null,
                                              ),
                                              SizedBox(width: sw(context, 10)),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        player.name,
                                                        style: t.titleMedium?.copyWith(
                                                          fontWeight: FontWeight.w600,
                                                          color: isDark ? Colors.white : Colors.black87,
                                                        ),
                                                      ),
                                                      if (item.isMe) ...[
                                                        SizedBox(width: sw(context, 6)),
                                                        Container(
                                                          padding: EdgeInsets.symmetric(
                                                            horizontal: sw(context, 4),
                                                            vertical: sh(context, 2),
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.blue.shade400,
                                                            borderRadius: BorderRadius.circular(sw(context, 4)),
                                                          ),
                                                          child: Text(
                                                            'YOU',
                                                            style: t.bodySmall?.copyWith(
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: st(context, 10),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                  SizedBox(height: sh(context, 2)),
                                                  Text(
                                                    item.completedAt.toLocal().toIso8601String().split('T').first,
                                                    style: t.bodySmall?.copyWith(
                                                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: sh(context, 8)),

                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: sw(context, 46),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${item.score} pts",
                                            style: t.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colorPrimary,
                                            ),
                                          ),
                                          SizedBox(height: sh(context, 4)),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.lightbulb,
                                                color: Colors.amber.shade500,
                                                size: 16,
                                              ),
                                              SizedBox(width: sw(context, 4)),
                                              Text(
                                                "${item.hintsUsed}",
                                                style: t.bodySmall,
                                              ),
                                              SizedBox(width: sw(context, 8)),
                                              Icon(
                                                Icons.close,
                                                color: Colors.red.shade400,
                                                size: 16,
                                              ),
                                              SizedBox(width: sw(context, 4)),
                                              Text(
                                                "${item.mistakes}",
                                                style: t.bodySmall,
                                              ),
                                              SizedBox(width: sw(context, 12)),
                                              Icon(
                                                Icons.access_time,
                                                color: Colors.blue.shade400,
                                                size: 16,
                                              ),
                                              SizedBox(width: sw(context, 4)),
                                              Text(
                                                "${item.completionTimeInSecs}s",
                                                style: t.bodySmall,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Rank icon + number
                                    Container(
                                      width: sw(context, 36),
                                      height: sw(context, 36),
                                      alignment: Alignment.center,
                                      child: item.rank <= 3
                                          ? Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Icon(
                                                  Icons.brightness_5_sharp,
                                                  size: 32,
                                                  color: item.rank == 1
                                                      ? Colors.amber
                                                      : item.rank == 2
                                                      ? Colors.grey
                                                      : Colors.brown,
                                                ),
                                                Text(
                                                  "${item.rank}",
                                                  style: t.titleMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: item.rank == 1
                                                            ? Colors.amber
                                                            : item.rank == 2
                                                            ? Colors.grey
                                                            : Colors.brown,
                                                        fontSize: st(
                                                          context,
                                                          16,
                                                        ),
                                                      ),
                                                ),
                                              ],
                                            )
                                          : Text(
                                              "${item.rank}",
                                              style: t.titleLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green.shade400,
                                                fontSize: st(context, 20),
                                              ),
                                            ),
                                    ),
                                    SizedBox(width: sw(context, 10)),

                                    // Avatar + Name + completedAt
                                    Expanded(
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: sw(context, 18),
                                            backgroundImage:
                                                (player.avatarUrl != null &&
                                                    player
                                                        .avatarUrl!
                                                        .isNotEmpty)
                                                ? NetworkImage(
                                                    player.avatarUrl!,
                                                  )
                                                : null,
                                            backgroundColor:
                                                Colors.grey.shade400,
                                            child:
                                                (player.avatarUrl == null ||
                                                    player.avatarUrl!.isEmpty)
                                                ? const Icon(
                                                    Icons.person,
                                                    color: Colors.white,
                                                    size: 20,
                                                  )
                                                : null,
                                          ),
                                          SizedBox(width: sw(context, 10)),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    player.name,
                                                    style: t.titleMedium?.copyWith(
                                                      fontWeight: FontWeight.w600,
                                                      color: isDark ? Colors.white : Colors.black87,
                                                    ),
                                                  ),
                                                  if (item.isMe) ...[
                                                    SizedBox(width: sw(context, 6)),
                                                    Container(
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: sw(context, 2),
                                                        vertical: sh(context, 2),
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue.shade400,
                                                        borderRadius: BorderRadius.circular(sw(context, 4)),
                                                      ),
                                                      child: Text(
                                                        'YOU',
                                                        style: t.bodySmall?.copyWith(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: st(context, 7),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              SizedBox(height: sh(context, 2)),
                                              Text(
                                                item.completedAt.toLocal().toIso8601String().split('T').first,
                                                style: t.bodySmall?.copyWith(
                                                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),

                                    // Score + hint/mistakes + completionTime
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "${item.score} pts",
                                          style: t.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colorPrimary,
                                          ),
                                        ),
                                        SizedBox(height: sh(context, 4)),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.lightbulb,
                                              color: Colors.amber.shade500,
                                              size: 16,
                                            ),
                                            SizedBox(width: sw(context, 4)),
                                            Text(
                                              "${item.hintsUsed}",
                                              style: t.bodySmall,
                                            ),
                                            SizedBox(width: sw(context, 8)),
                                            Icon(
                                              Icons.close,
                                              color: Colors.red.shade400,
                                              size: 16,
                                            ),
                                            SizedBox(width: sw(context, 4)),
                                            Text(
                                              "${item.mistakes}",
                                              style: t.bodySmall,
                                            ),
                                            SizedBox(width: sw(context, 12)),
                                            Icon(
                                              Icons.access_time,
                                              color: Colors.blue.shade400,
                                              size: 16,
                                            ),
                                            SizedBox(width: sw(context, 4)),
                                            Text(
                                              "${item.completionTimeInSecs}s",
                                              style: t.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                        },
                      ),
                    ).animate().fadeIn(duration: 350.ms, delay: (entry.key * 80).ms),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}
