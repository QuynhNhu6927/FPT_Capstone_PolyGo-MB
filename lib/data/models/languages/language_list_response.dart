import '../api_response.dart';
import 'language_model.dart';

class LanguageListResponse {
  final List<LanguageModel> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;

  LanguageListResponse({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
  });

  factory LanguageListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final List<dynamic> itemList = data['items'] ?? [];

    return LanguageListResponse(
      items: itemList.map((e) => LanguageModel.fromJson(e)).toList(),
      totalItems: data['totalItems'] ?? 0,
      currentPage: data['currentPage'] ?? 1,
      totalPages: data['totalPages'] ?? 1,
      pageSize: data['pageSize'] ?? 0,
    );
  }
}
