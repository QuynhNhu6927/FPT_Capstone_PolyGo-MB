
import 'me_interests_model.dart';

class MeInterestListResponse {
  final List<MeInterestModel> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int pageSize;

  MeInterestListResponse({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
  });

  factory MeInterestListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final List<dynamic> itemList = data['items'] ?? [];

    return MeInterestListResponse(
      items: itemList.map((e) => MeInterestModel.fromJson(e)).toList(),
      totalItems: data['totalItems'] ?? 0,
      currentPage: data['currentPage'] ?? 1,
      totalPages: data['totalPages'] ?? 1,
      pageSize: data['pageSize'] ?? 0,
    );
  }
}
