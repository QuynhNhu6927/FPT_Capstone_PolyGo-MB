import '../api_response.dart';
import 'interest_model.dart';

class InterestListResponse {
  final List<InterestModel> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;

  InterestListResponse({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
  });

  factory InterestListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final List<dynamic> itemList = data['items'] ?? [];

    return InterestListResponse(
      items: itemList.map((e) => InterestModel.fromJson(e)).toList(),
      totalItems: data['totalItems'] ?? 0,
      currentPage: data['currentPage'] ?? 1,
      totalPages: data['totalPages'] ?? 1,
      pageSize: data['pageSize'] ?? 0,
    );
  }
}
