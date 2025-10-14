// repositories/gift_repository.dart
import '../models/gift/gift_list_response.dart';
import '../services/gift_service.dart';

class GiftRepository {
  final GiftService _service;

  GiftRepository(this._service);

  Future<GiftListResponse?> getGifts({
    required String token,
    int pageNumber = 1,
    int pageSize = 10,
    String? lang,
  }) async {
    try {
      final res = await _service.getGifts(
        token: token,
        pageNumber: pageNumber,
        pageSize: pageSize,
        lang: lang,
      );
      return res.data;
    } catch (e) {
      rethrow;
    }
  }
}
