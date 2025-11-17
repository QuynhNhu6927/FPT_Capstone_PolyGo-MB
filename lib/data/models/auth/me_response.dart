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
  final bool autoRenewSubscription;
  final int streakDays;
  final int withdrawTimes;
  final bool isNew;
  final String planType;
  final double balance;
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
    required this.experiencePoints,
    required this.role,
    required this.autoRenewSubscription,
    required this.streakDays,
    required this.withdrawTimes,
    required this.isNew,
    required this.planType,
    required this.balance,
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
          : int.tryParse(json['experiencePoints']?.toString() ?? '0') ?? 0,
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
      withdrawTimes: (json['withdrawTimes'] is int)
          ? json['withdrawTimes'] as int
          : int.tryParse(json['streakDays']?.toString() ?? '0') ?? 0,
      isNew: json['isNew'] == true,
      planType: json['planType']?.toString() ?? '',
      balance: (json['balance'] is num)
          ? (json['balance'] as num).toDouble()
          : double.tryParse(json['balance']?.toString() ?? '0') ?? 0.0,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.tryParse(json['lastLoginAt'])
          : null,
      nextWithdrawResetAt: json['nextWithdrawResetAt'] != null
          ? DateTime.tryParse(json['nextWithdrawResetAt'])
          : null,
    );
  }
}
