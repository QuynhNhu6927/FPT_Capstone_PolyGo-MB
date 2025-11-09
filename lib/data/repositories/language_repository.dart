import '../models/languages/language_model.dart';
import '../models/languages/language_list_response.dart';
import '../models/languages/learn_language_model.dart';
import '../models/languages/speak_language_model.dart';
import '../services/apis/language_service.dart';

class LanguageRepository {
  final LanguageService _service;

  LanguageRepository(this._service);

  Future<List<LanguageModel>> getAllLanguages(String token, {String lang = 'vi'}) async {
    final res = await _service.getLanguages(token: token, lang: lang);
    if (res.data == null)
      {
        // throw Exception(res.message ?? 'Get languages failed');
      }
    return res.data!.items;
  }

  Future<LanguageModel> getLanguageById(String id, String token) async {
    final res = await _service.getLanguageById(id, token);
    if (res.data == null)
      {
        // throw Exception(res.message ?? 'Get language failed');
      }
    return res.data!;
  }

  /// Get all speaking languages for current user
  Future<List<SpeakLanguageModel>> getSpeakingLanguagesMeAll(String token, {String lang = 'vi'}) async {
    final res = await _service.getSpeakingLanguagesMeAll(token: token, lang: lang);
    if (res.data == null) return [];
    return res.data!.items;
  }

  /// Get all learning languages for current user
  Future<List<LearnLanguageModel>> getLearningLanguagesMeAll(String token, {String lang = 'vi'}) async {
    final res = await _service.getLearningLanguagesMeAll(token: token, lang: lang);
    if (res.data == null) return [];
    return res.data!.items;
  }

  /// Get learning languages for current user (new endpoint)
  Future<List<LearnLanguageModel>> getLearningLanguagesMe(String token, {String lang = 'vi'}) async {
    final res = await _service.getLearningLanguagesMe(token: token, lang: lang);
    if (res.data == null) return [];
    return res.data!.items;
  }

  /// Get speaking languages for current user (new endpoint)
  Future<List<SpeakLanguageModel>> getSpeakingLanguagesMe(String token, {String lang = 'vi'}) async {
    final res = await _service.getSpeakingLanguagesMe(token: token, lang: lang);
    if (res.data == null) return [];
    return res.data!.items;
  }

}
