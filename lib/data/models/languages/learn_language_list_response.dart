import 'learn_language_model.dart';

class LearnLanguageListResponse {
  final List<LearnLanguageModel> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;

  LearnLanguageListResponse({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
  });

  factory LearnLanguageListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final List<dynamic> itemList = data['items'] ?? [];

    return LearnLanguageListResponse(
      items: itemList.map((e) => LearnLanguageModel.fromJson(e)).toList(),
      totalItems: data['totalItems'] ?? 0,
      currentPage: data['currentPage'] ?? 1,
      totalPages: data['totalPages'] ?? 1,
      pageSize: data['pageSize'] ?? 0,
    );
  }
}
