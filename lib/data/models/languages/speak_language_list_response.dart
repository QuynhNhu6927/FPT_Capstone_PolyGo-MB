import 'package:polygo_mobile/data/models/languages/speak_language_model.dart';

class SpeakLanguageListResponse {
  final List<SpeakLanguageModel> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;

  SpeakLanguageListResponse({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
  });

  factory SpeakLanguageListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final List<dynamic> itemList = data['items'] ?? [];

    return SpeakLanguageListResponse(
      items: itemList.map((e) => SpeakLanguageModel.fromJson(e)).toList(),
      totalItems: data['totalItems'] ?? 0,
      currentPage: data['currentPage'] ?? 1,
      totalPages: data['totalPages'] ?? 1,
      pageSize: data['pageSize'] ?? 0,
    );
  }
}
