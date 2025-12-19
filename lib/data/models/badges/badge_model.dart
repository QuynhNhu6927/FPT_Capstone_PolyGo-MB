class BadgeModel {
  final String id;
  final String lang;
  final String code;
  final String name;
  final String description;
  final String iconUrl;
  final String badgeCategory;
  final String createdAt;
  final String claimedAt;
  final String lastUpdatedAt;
  final bool has;
  final bool isClaimed;

  BadgeModel({
    required this.id,
    required this.lang,
    required this.code,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.badgeCategory,
    required this.createdAt,
    required this.claimedAt,
    required this.lastUpdatedAt,
    required this.has,
    required this.isClaimed,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id']?.toString() ?? '',
      lang: json['lang']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      iconUrl: json['iconUrl']?.toString() ?? '',
      badgeCategory: json['badgeCategory']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      claimedAt: json['claimedAt']?.toString() ?? '',
      lastUpdatedAt: json['lastUpdatedAt']?.toString() ?? '',
      has: json['has'] == true,
      isClaimed: json['isClaimed'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lang': lang,
      'code': code,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'badgeCategory': badgeCategory,
      'createdAt': createdAt,
      'claimedAt': claimedAt,
      'lastUpdatedAt': lastUpdatedAt,
      'has': has,
      'isClaimed': isClaimed,
    };
  }

  BadgeModel copyWith({
    String? id,
    String? lang,
    String? code,
    String? name,
    String? description,
    String? iconUrl,
    String? badgeCategory,
    String? createdAt,
    String? claimedAt,
    String? lastUpdatedAt,
    bool? has,
    bool? isClaimed,
  }) {
    return BadgeModel(
      id: id ?? this.id,
      lang: lang ?? this.lang,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      badgeCategory: badgeCategory ?? this.badgeCategory,
      createdAt: createdAt ?? this.createdAt,
      claimedAt: claimedAt ?? this.claimedAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      has: has ?? this.has,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }
}

class ClaimBadgeResponse {
  final String message;

  ClaimBadgeResponse({required this.message});

  factory ClaimBadgeResponse.fromJson(Map<String, dynamic> json) {
    return ClaimBadgeResponse(
      message: json['message'] ?? '',
    );
  }
}