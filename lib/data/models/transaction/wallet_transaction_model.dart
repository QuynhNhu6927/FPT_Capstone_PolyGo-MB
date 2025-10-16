class WalletTransaction {
  final String id;
  final double amount;
  final double remainingBalance;
  final String transactionType;
  final String transactionMethod;
  final String transactionStatus;
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.amount,
    required this.remainingBalance,
    required this.transactionType,
    required this.transactionMethod,
    required this.transactionStatus,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      remainingBalance: (json['remainingBalance'] as num?)?.toDouble() ?? 0,
      transactionType: json['transactionType'] ?? '',
      transactionMethod: json['transactionMethod'] ?? '',
      transactionStatus: json['transactionStatus'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
