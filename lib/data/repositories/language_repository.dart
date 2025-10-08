import '../models/languages/language_model.dart';
import '../models/languages/language_list_response.dart';
import '../services/language_service.dart';

class LanguageRepository {
  final LanguageService _service;

  LanguageRepository(this._service);

  Future<List<LanguageModel>> getAllLanguages(String token, {String lang = 'vi'}) async {
    final res = await _service.getLanguages(token: token, lang: lang);
    if (res.data == null) throw Exception(res.message ?? 'Get languages failed');
    return res.data!.items;
  }

  Future<LanguageModel> getLanguageById(String id, String token) async {
    final res = await _service.getLanguageById(id, token);
    if (res.data == null) throw Exception(res.message ?? 'Get language failed');
    return res.data!;
  }
}
