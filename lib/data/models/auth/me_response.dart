class MeResponse {
  final String id;
  final String name;
  final String mail;
  final String? avatarUrl;
  final int merit;
  final String introduction;
  final String gender;
  final int experiencePoints;
  final String role;
  final int numberOfUnreadMessages;
  final int numberOfUnreadNotifications;
  final bool autoRenewSubscription;
  final int streakDays;
  final int longestStreakDays;
  final int withdrawTimes;
  final bool isNew;
  final String planType;
  final double balance;
  final int level;
  final int xpInCurrentLevel;
  final int xpToNextLevel;
  final DateTime? nextWithdrawResetAt;
  final DateTime? lastLoginAt;

  MeResponse({
    required this.id,
    required this.name,
    required this.mail,
    this.avatarUrl,
    required this.merit,
    required this.introduction,
    required this.gender,
    required this.numberOfUnreadNotifications,
    required this.numberOfUnreadMessages,
    required this.experiencePoints,
    required this.role,
    required this.autoRenewSubscription,
    required this.streakDays,
    required this.longestStreakDays,
    required this.withdrawTimes,
    required this.isNew,
    required this.planType,
    required this.balance,
    required this.level,
    required this.xpInCurrentLevel,
    required this.xpToNextLevel,
    this.nextWithdrawResetAt,
    this.lastLoginAt,
  });

  factory MeResponse.fromJson(Map<String, dynamic> json) {
    return MeResponse(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      mail: json['mail']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
      merit: (json['merit'] is int)
          ? json['merit'] as int
          : int.tryParse(json['merit']?.toString() ?? '0') ?? 0,
      introduction: json['introduction']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      experiencePoints: (json['experiencePoints'] is int)
          ? json['experiencePoints'] as int
          : int.tryParse(json['experiencePoints']?.toString() ?? '0') ?? 0,
      role: json['role']?.toString() ?? '',
      autoRenewSubscription: json['autoRenewSubscription'] == true,
      streakDays: (json['streakDays'] is int)
          ? json['streakDays'] as int
          : int.tryParse(json['streakDays']?.toString() ?? '0') ?? 0,
      longestStreakDays: (json['longestStreakDays'] is int)
          ? json['longestStreakDays'] as int
          : int.tryParse(json['longestStreakDays']?.toString() ?? '0') ?? 0,
      numberOfUnreadMessages: (json['numberOfUnreadMessages'] is int)
          ? json['numberOfUnreadMessages'] as int
          : int.tryParse(json['numberOfUnreadMessages']?.toString() ?? '0') ?? 0,
      numberOfUnreadNotifications: (json['numberOfUnreadNotifications'] is int)
          ? json['numberOfUnreadNotifications'] as int
          : int.tryParse(json['longestStreakDays']?.toString() ?? '0') ?? 0,
      withdrawTimes: (json['withdrawTimes'] is int)
          ? json['withdrawTimes'] as int
          : int.tryParse(json['withdrawTimes']?.toString() ?? '0') ?? 0,
      isNew: json['isNew'] == true,
      planType: json['planType']?.toString() ?? '',
      balance: (json['balance'] is num)
          ? (json['balance'] as num).toDouble()
          : double.tryParse(json['balance']?.toString() ?? '0') ?? 0.0,
      level: (json['level'] is int)
          ? json['level'] as int
          : int.tryParse(json['level']?.toString() ?? '0') ?? 0,
      xpInCurrentLevel: (json['xpInCurrentLevel'] is int)
          ? json['xpInCurrentLevel'] as int
          : int.tryParse(json['xpInCurrentLevel']?.toString() ?? '0') ?? 0,
      xpToNextLevel: (json['xpToNextLevel'] is int)
          ? json['xpToNextLevel'] as int
          : int.tryParse(json['xpToNextLevel']?.toString() ?? '0') ?? 0,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.tryParse(json['lastLoginAt'])
          : null,
      nextWithdrawResetAt: json['nextWithdrawResetAt'] != null
          ? DateTime.tryParse(json['nextWithdrawResetAt'])
          : null,
    );
  }
}
