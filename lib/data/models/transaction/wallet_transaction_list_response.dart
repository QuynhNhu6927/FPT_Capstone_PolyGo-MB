import 'package:polygo_mobile/data/models/transaction/wallet_transaction_model.dart';

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
