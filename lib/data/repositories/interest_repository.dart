import '../models/interests/interest_model.dart';
import '../models/interests/interest_list_response.dart';
import '../services/interest_service.dart';

class InterestRepository {
  final InterestService _service;

  InterestRepository(this._service);

  /// Get all interests
  Future<List<InterestModel>> getAllInterests(String token, {String lang = 'vi'}) async {
    final res = await _service.getInterests(token: token, lang: lang);
    if (res.data == null) throw Exception(res.message ?? 'Get interests failed');
    return res.data!.items;
  }

  /// Get single interest
  Future<InterestModel> getInterestById(String id, String token) async {
    final res = await _service.getInterestById(id, token);
    if (res.data == null) throw Exception(res.message ?? 'Get interest failed');
    return res.data!;
  }
}
