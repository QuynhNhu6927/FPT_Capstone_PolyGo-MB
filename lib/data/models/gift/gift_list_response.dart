import 'gift_model.dart';

class GiftListResponse {
  final List<GiftModel> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;

  GiftListResponse({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
  });

  factory GiftListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final List<dynamic> list = data['items'] ?? [];

    return GiftListResponse(
      items: list.map((e) => GiftModel.fromJson(e)).toList(),
      totalItems: data['totalItems'] ?? 0,
      currentPage: data['currentPage'] ?? 1,
      totalPages: data['totalPages'] ?? 1,
      pageSize: data['pageSize'] ?? 0,
    );
  }
}
