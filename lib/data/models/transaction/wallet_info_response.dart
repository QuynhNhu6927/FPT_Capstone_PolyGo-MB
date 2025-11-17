class WalletInfoResponse {
  final String id;
  final double balance;
  final double pendingBalance;
  final double totalSpent;
  final double totalEarned;
  final double totalWithdrawn;
  final List<WalletAccount> accounts;
  final int numberOfAccounts;

  WalletInfoResponse({
    required this.id,
    required this.balance,
    required this.pendingBalance,
    required this.totalSpent,
    required this.totalEarned,
    required this.totalWithdrawn,
    required this.accounts,
    required this.numberOfAccounts,
  });

  factory WalletInfoResponse.fromJson(Map<String, dynamic> json) {
    final accountsJson = json['accounts'] is List ? json['accounts'] as List : [];
    return WalletInfoResponse(
      id: json['id'] as String? ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      pendingBalance: (json['pendingBalance'] as num?)?.toDouble() ?? 0.0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      totalEarned: (json['totalEarned'] as num?)?.toDouble() ?? 0.0,
      totalWithdrawn: (json['totalWithdrawn'] as num?)?.toDouble() ?? 0.0,
      accounts: accountsJson.map((e) {
        if (e is Map<String, dynamic>) return WalletAccount.fromJson(e);
        return WalletAccount(id: '', bankName: '', bankNumber: '', accountName: '');
      }).toList(),
      numberOfAccounts: json['numberOfAccounts'] as int? ?? 0,
    );
  }
}

class WalletAccount {
  final String id;
  final String bankName;
  final String bankNumber;
  final String accountName;

  WalletAccount({
    required this.id,
    required this.bankName,
    required this.bankNumber,
    required this.accountName,
  });

  factory WalletAccount.fromJson(Map<String, dynamic> json) {
    return WalletAccount(
      id: json['id'] as String? ?? '',
      bankName: json['bankName'] as String? ?? '',
      bankNumber: json['bankNumber'] as String? ?? '',
      accountName: json['accountName'] as String? ?? '',
    );
  }
}
