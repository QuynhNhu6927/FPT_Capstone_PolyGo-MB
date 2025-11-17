class WalletTransaction {
  final String id;
  final double amount;
  final double remainingBalance;
  final String description;
  final String userNotes;
  bool isInquiry;
  final String transactionType;
  final String transactionMethod;
  final String transactionStatus;
  final String bankNumber;
  final String accountName;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;

  WalletTransaction({
    required this.id,
    required this.amount,
    required this.remainingBalance,
    required this.description,
    required this.userNotes,
    this.isInquiry = false,
    required this.transactionType,
    required this.transactionMethod,
    required this.transactionStatus,
    required this.bankNumber,
    required this.accountName,
    required this.createdAt,
    required this.lastUpdatedAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      remainingBalance: (json['remainingBalance'] as num?)?.toDouble() ?? 0,

      description: json['description'] ?? '',
      userNotes: json['userNotes'] ?? '',
      isInquiry: json['isInquiry'] ?? false,

      transactionType: json['transactionType'] ?? '',
      transactionMethod: json['transactionMethod'] ?? '',
      transactionStatus: json['transactionStatus'] ?? '',
      bankNumber: json['bankNumber'] ?? '',
      accountName: json['accountName'] ?? '',

      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      lastUpdatedAt: DateTime.tryParse(json['lastUpdatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class WalletTransactionListResponse {
  final List<WalletTransaction> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  WalletTransactionListResponse({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory WalletTransactionListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return WalletTransactionListResponse(
      items: (data['items'] as List<dynamic>?)
          ?.map((e) => WalletTransaction.fromJson(e))
          .toList() ??
          [],
      totalItems: data['totalItems'] ?? 0,
      currentPage: data['currentPage'] ?? 1,
      totalPages: data['totalPages'] ?? 1,
      pageSize: data['pageSize'] ?? 10,
      hasPreviousPage: data['hasPreviousPage'] ?? false,
      hasNextPage: data['hasNextPage'] ?? false,
    );
  }
}
