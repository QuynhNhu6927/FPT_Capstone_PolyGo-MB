import 'package:flutter/cupertino.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/api_constants.dart';
import '../../models/api_response.dart';
import '../../models/wordsets/game_state_response.dart';
import '../../models/wordsets/hint_response.dart';
import '../../models/wordsets/joined_word_set.dart';
import '../../models/wordsets/leaderboard_model.dart';
import '../../models/wordsets/play_word_response.dart';
import '../../models/wordsets/start_wordset_response.dart';
import '../../models/wordsets/word_sets_model.dart';

class WordSetService {
  final ApiClient apiClient;

  WordSetService(this.apiClient);

  Future<ApiResponse<PlayedWordSetListResponse>> getPlayedWordSets({
    required String token,
    String? lang,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final queryParameters = <String, dynamic>{
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };

    if (lang != null) queryParameters['lang'] = lang;

    final response = await apiClient.get(
      ApiConstants.joinedGame,
      queryParameters: queryParameters,
      headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
    );

    final json = response.data as Map<String, dynamic>;
    return ApiResponse.fromJson(
      json,
          (data) => PlayedWordSetListResponse.fromJson(json['data']),
    );
  }

  Future<ApiResponse<WordSetListResponse>> getWordSets({
    required String token,
    String? lang,
    String? name,
    List<String>? languageIds,
    String? difficulty,
    String? category,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final queryParameters = <String, dynamic>{
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };

    if (lang != null) queryParameters['lang'] = lang;
    if (name != null) queryParameters['name'] = name;
    if (languageIds != null && languageIds.isNotEmpty)
      queryParameters['languageIds'] = languageIds;
    if (difficulty != null) queryParameters['difficulty'] = difficulty;
    if (category != null) queryParameters['category'] = category;

    final response = await apiClient.get(
      ApiConstants.allWordSets,
      queryParameters: queryParameters,
      headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
    );

    final json = response.data as Map<String, dynamic>;
    return ApiResponse.fromJson(
      json,
          (data) => WordSetListResponse.fromJson(data),
    );
  }

  Future<ApiResponse<WordSetListResponse>> getCreatedWordSets({
    required String token,
    String? lang,
    String? name,
    List<String>? languageIds,
    String? difficulty,
    String? category,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final queryParameters = <String, dynamic>{
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };

    if (lang != null) queryParameters['lang'] = lang;
    if (name != null) queryParameters['name'] = name;
    if (languageIds != null && languageIds.isNotEmpty)
      queryParameters['languageIds'] = languageIds;
    if (difficulty != null) queryParameters['difficulty'] = difficulty;
    if (category != null) queryParameters['category'] = category;

    final response = await apiClient.get(
      ApiConstants.createdGame,
      queryParameters: queryParameters,
      headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
    );

    final json = response.data as Map<String, dynamic>;
    return ApiResponse.fromJson(
      json,
          (data) => WordSetListResponse.fromJson(data),
    );
  }

  Future<ApiResponse<LeaderboardResponse>> getLeaderboard({
    required String token,
    required String wordSetId,
    String? lang,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final queryParameters = <String, dynamic>{
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };
    if (lang != null) queryParameters['lang'] = lang;

    final endpoint =
    ApiConstants.wordSetLeaderBoard.replaceAll('{wordSetId}', wordSetId);

    final response = await apiClient.get(
      endpoint,
      queryParameters: queryParameters,
      headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
    );

    final json = response.data as Map<String, dynamic>;
    return ApiResponse.fromJson(
      json,
          (data) => LeaderboardResponse.fromJson(data),
    );
  }

  Future<ApiResponse<WordSetModel>> getWordSetById({
    required String token,
    required String id,
    String? lang,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (lang != null) queryParameters['lang'] = lang;

    final endpoint = ApiConstants.wordSetsById.replaceAll('{id}', id);

    final response = await apiClient.get(
      endpoint,
      queryParameters: queryParameters,
      headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
    );

    final json = response.data as Map<String, dynamic>;
    return ApiResponse.fromJson(
      json,
          (data) => WordSetModel.fromJson(data),
    );
  }

  Future<ApiResponse<StartWordSetResponse>> startWordSet({
    required String token,
    required String wordSetId,
  }) async {
    final endpoint = ApiConstants.startGame.replaceAll('{wordSetId}', wordSetId);

    final response = await apiClient.post(
      endpoint,
      headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      data: {},
    );

    final json = response.data as Map<String, dynamic>?;

    if (json == null || json['data'] == null) {
      throw Exception("StartWordSet API returned null data");
    }

    return ApiResponse.fromJson(
      json,
          (data) => StartWordSetResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<PlayWordResponse?> playWord({
    required String token,
    required String wordSetId,
    required String wordId,
    required String answer,
  }) async {
    final body = {
      "wordSetId": wordSetId,
      "wordId": wordId,
      "answer": answer,
    };

    final response = await apiClient.post(
      ApiConstants.playGame,
      headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      data: body,
    );

    if (response.data == null) return null;

    final json = response.data as Map<String, dynamic>;
    return PlayWordResponse.fromJson(json);
  }

  Future<ApiResponse<GameStateResponse>> getHint({
    required String token,
    required String wordSetId,
  }) async {
    final endpoint = ApiConstants.hintGame.replaceAll('{wordSetId}', wordSetId);

    final response = await apiClient.get(
      endpoint,
      headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
    );

    final json = response.data as Map<String, dynamic>;
    final apiResponse = ApiResponse.fromJson(
      json,
          (_) => GameStateResponse.fromJson(json),
    );

    return apiResponse;
  }

  Future<ApiResponse<HintResponse>> addHint({
    required String token,
    required String wordSetId,
    required String wordId,
  }) async {
    final endpoint = ApiConstants.plusHint.replaceAll('{wordSetId}', wordSetId);

    final response = await apiClient.post(
      endpoint,
      headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      data: {'wordId': wordId},
    );

    final json = response.data as Map<String, dynamic>;

    return ApiResponse.fromJson(
      json,
          (data) => HintResponse.fromJson(data['data'] as Map<String, dynamic>),
    );
  }

}
