import '../models/wordsets/game_state_response.dart';
import '../models/wordsets/hint_response.dart';
import '../models/wordsets/joined_word_set.dart';
import '../models/wordsets/leaderboard_model.dart';
import '../models/wordsets/play_word_response.dart';
import '../models/wordsets/start_wordset_response.dart';
import '../models/wordsets/word_sets_model.dart';
import '../services/apis/wordset_service.dart';

class WordSetRepository {
  final WordSetService _service;

  WordSetRepository(this._service);

  Future<WordSetListResponse> getWordSetsPaged(
      String token, {
        String? lang,
        String? name,
        List<String>? languageIds,
        String? difficulty,
        String? category,
        int pageNumber = 1,
        int pageSize = 10,
      }) async {
    final res = await _service.getWordSets(
      token: token,
      lang: lang,
      name: name,
      languageIds: languageIds,
      difficulty: difficulty,
      category: category,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    if (res.data == null) {
      return WordSetListResponse(
        items: [],
        totalItems: 0,
        currentPage: 1,
        totalPages: 1,
        pageSize: pageSize,
        hasPreviousPage: false,
        hasNextPage: false,
      );
    }

    return res.data!;
  }

  Future<WordSetListResponse> getCreatedWordSetsPaged(
      String token, {
        String? lang,
        String? name,
        List<String>? languageIds,
        String? difficulty,
        String? category,
        int pageNumber = 1,
        int pageSize = 10,
      }) async {
    final res = await _service.getCreatedWordSets(
      token: token,
      lang: lang,
      name: name,
      languageIds: languageIds,
      difficulty: difficulty,
      category: category,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    if (res.data == null) {
      return WordSetListResponse(
        items: [],
        totalItems: 0,
        currentPage: 1,
        totalPages: 1,
        pageSize: pageSize,
        hasPreviousPage: false,
        hasNextPage: false,
      );
    }

    return res.data!;
  }

  Future<LeaderboardResponse> getLeaderboard(
      String token, {
        required String wordSetId,
        String? lang,
        int pageNumber = 1,
        int pageSize = 10,
      }) async {
    final res = await _service.getLeaderboard(
      token: token,
      wordSetId: wordSetId,
      lang: lang,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    if (res.data == null) {
      return LeaderboardResponse(
        items: [],
        totalItems: 0,
        currentPage: 1,
        totalPages: 1,
        pageSize: pageSize,
        hasPreviousPage: false,
        hasNextPage: false,
      );
    }

    return res.data!;
  }

  Future<PlayedWordSetListResponse> getPlayedWordSetsPaged(
      String token, {
        String? lang,
        int pageNumber = 1,
        int pageSize = 10,
      }) async {
    final res = await _service.getPlayedWordSets(
      token: token,
      lang: lang,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    if (res.data == null) {
      return PlayedWordSetListResponse(
        items: [],
        totalItems: 0,
        currentPage: 1,
        totalPages: 1,
        pageSize: pageSize,
        hasPreviousPage: false,
        hasNextPage: false,
      );
    }

    return res.data!;
  }

  Future<WordSetModel?> getWordSetById({
    required String token,
    required String id,
    String? lang,
  }) async {
    final res = await _service.getWordSetById(
      token: token,
      id: id,
      lang: lang,
    );
    return res.data;
  }

  Future<StartWordSetResponse?> startWordSet({
    required String token,
    required String wordSetId,
  }) async {
    final res = await _service.startWordSet(token: token, wordSetId: wordSetId);
    return res.data;
  }

  Future<PlayWordData?> playWord({
    required String token,
    required String wordSetId,
    required String wordId,
    required String answer,
  }) async {
    final res = await _service.playWord(
      token: token,
      wordSetId: wordSetId,
      wordId: wordId,
      answer: answer,
    );

    if (res == null) return null;

    return res.data;
  }

  Future<GameStateResponse?> getHint({
    required String token,
    required String wordSetId,
  }) async {
    final res = await _service.getHint(token: token, wordSetId: wordSetId);
    return res.data;
  }

  Future<HintResponse?> addHint({
    required String token,
    required String wordSetId,
    required String wordId,
  }) async {
    final res = await _service.addHint(
      token: token,
      wordSetId: wordSetId,
      wordId: wordId,
    );

    return res.data;
  }
}
