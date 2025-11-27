import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/api_constants.dart';
import '../../models/api_response.dart';
import '../../models/chat/conversation_message_model.dart';
import '../../models/chat/conversation_model.dart';
import '../../models/chat/get_images_model.dart';
import '../../models/chat/get_translate_language.dart';
import '../../models/chat/translate_message.dart';
import '../../models/chat/update_trans_lang.dart';

class ConversationService {
  final ApiClient apiClient;

  ConversationService(this.apiClient);

  Future<ApiResponse<ConversationListResponse>> getConversations({
    required String token,
    int pageNumber = 1,
    int pageSize = 10,
    String? name,
  }) async {
    try {
      final queryParameters = {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        if (name != null) 'name': name,
      };

      final response = await apiClient.get(
        ApiConstants.allConversations,
        queryParameters: queryParameters,
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => ConversationListResponse.fromJson(data),
      );
    } on DioError catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<ConversationMessageListResponse>> getConversationMessages({
    required String token,
    required String conversationId,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await apiClient.get(
        ApiConstants.getConversation.replaceFirst('{id}', conversationId),
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
        },
      );

      final json = response.data as Map<String, dynamic>;
      final dataJson = json['data'] as Map<String, dynamic>?;

      return ApiResponse.fromJson(
        json,
            (data) => dataJson != null
            ? ConversationMessageListResponse.fromJson(dataJson)
            : ConversationMessageListResponse(
          items: [],
          totalItems: 0,
          currentPage: 1,
          totalPages: 1,
          pageSize: pageSize,
          hasPreviousPage: false,
          hasNextPage: false,
        ),
      );
    } on DioError catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<Conversation>> getConversationById({
    required String token,
    required String conversationId,
  }) async {
    try {
      final response = await apiClient.get(
        ApiConstants.getConversationById.replaceFirst('{id}', conversationId),
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
        },
      );

      final json = response.data as Map<String, dynamic>;
      final dataJson = json['data'] as Map<String, dynamic>?;

      return ApiResponse.fromJson(
        json,
            (data) => dataJson != null
            ? Conversation.fromJson(dataJson)
            : throw Exception("Conversation data is null"),
      );
    } on DioError catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<Conversation>> getConversationByUser({
    required String token,
    required String userId,
  }) async {
    try {
      final response = await apiClient.get(
        ApiConstants.getConversationByUser.replaceFirst('{userId}', userId),
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
        },
      );

      final json = response.data as Map<String, dynamic>;
      final dataJson = json['data'] as Map<String, dynamic>?;

      return ApiResponse.fromJson(
        json,
            (data) => dataJson != null
            ? Conversation.fromJson(dataJson)
            : throw Exception("Conversation data is null"),
      );
    } on DioError catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<TranslatedMessage>> translateMessage({
    required String token,
    required String messageId,
  }) async {
    try {
      final endpoint = ApiConstants.transMessage.replaceFirst('{messageId}', messageId);

      final response = await apiClient.post(
        endpoint,
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
        },
      );

      final json = response.data as Map<String, dynamic>;
      final dataJson = json['data'] as Map<String, dynamic>?;

      return ApiResponse.fromJson(
        json,
            (data) => dataJson != null
            ? TranslatedMessage.fromJson(dataJson)
            : throw Exception("No data in translateMessage response"),
      );
    } on DioError catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<ConversationTranslationLanguage>> getTranslationLanguage({
    required String token,
    required String conversationId,
  }) async {
    try {
      final endpoint = ApiConstants.getTransLang.replaceFirst('{conversationId}', conversationId);

      final response = await apiClient.get(
        endpoint,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final json = response.data as Map<String, dynamic>;
      final dataJson = json['data'] as Map<String, dynamic>?;

      return ApiResponse.fromJson(
        json,
            (data) => dataJson != null
            ? ConversationTranslationLanguage.fromJson(dataJson)
            : throw Exception("No data in getTranslationLanguage response"),
      );
    } on DioError catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<void>> updateTranslationLanguage({
    required String token,
    required String conversationId,
    required String languageCode,
  }) async {
    try {
      final endpoint = ApiConstants.updateTransLang.replaceFirst(
          '{conversationId}', conversationId);

      final body = UpdateTranslationLanguageRequest(languageCode: languageCode);

      final response = await apiClient.put(
        endpoint,
        data: body.toJson(),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(json, (_) => null);
    } on DioError catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<ConversationImagesResponse>> getConversationImages({
    required String token,
    required String conversationId,
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await apiClient.get(
        ApiConstants.getImages.replaceFirst('{id}', conversationId),
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
        },
      );

      final json = response.data as Map<String, dynamic>;

      return ApiResponse.fromJson(
        json,
            (data) => ConversationImagesResponse.fromJson(data),
      );
    } on DioError catch (e) {
      rethrow;
    }
  }

}
