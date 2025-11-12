class LeaderboardItem {
  final int rank;
  final Player player;
  final int completionTimeInSecs;
  final int score;
  final int mistakes;
  final int hintsUsed;
  final int xpEarned;
  final DateTime completedAt;
  final bool isMe;

  LeaderboardItem({
    required this.rank,
    required this.player,
    required this.completionTimeInSecs,
    required this.score,
    required this.mistakes,
    required this.hintsUsed,
    required this.xpEarned,
    required this.completedAt,
    required this.isMe,
  });

  factory LeaderboardItem.fromJson(Map<String, dynamic> json) =>
      LeaderboardItem(
        rank: json['rank'],
        player: Player.fromJson(json['player']),
        completionTimeInSecs: json['completionTimeInSecs'],
        score: json['score'],
        mistakes: json['mistakes'],
        hintsUsed: json['hintsUsed'],
        xpEarned: json['xpEarned'],
        completedAt: DateTime.parse(json['completedAt']),
        isMe: json['isMe'],
      );
}

class Player {
  final String id;
  final String name;
  final String? avatarUrl;

  Player({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json['id'],
    name: json['name'],
    avatarUrl: json['avatarUrl'],
  );
}

class LeaderboardResponse {
  final List<LeaderboardItem> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  LeaderboardResponse({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) =>
      LeaderboardResponse(
        items: (json['items'] as List)
            .map((e) => LeaderboardItem.fromJson(e))
            .toList(),
        totalItems: json['totalItems'],
        currentPage: json['currentPage'],
        totalPages: json['totalPages'],
        pageSize: json['pageSize'],
        hasPreviousPage: json['hasPreviousPage'],
        hasNextPage: json['hasNextPage'],
      );
}
