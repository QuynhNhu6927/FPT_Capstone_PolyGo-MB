import '../models/chat/conversation_message_model.dart';
import '../models/chat/conversation_model.dart';
import '../models/chat/get_images_model.dart';
import '../models/chat/get_translate_language.dart';
import '../models/chat/translate_message.dart';
import '../services/apis/conversation_service.dart';

class ConversationRepository {
  final ConversationService _service;

  ConversationRepository(this._service);

  /// Lấy conversation với phân trang
  Future<ConversationListResponse> getConversationsPaged({
    required String token,
    int pageNumber = 1,
    int pageSize = 10,
    String? name,
  }) async {
    final res = await _service.getConversations(
      token: token,
      pageNumber: pageNumber,
      pageSize: pageSize,
      name: name,
    );

    if (res.data == null) {
      return ConversationListResponse(
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

  /// Lấy tất cả conversation (không phân trang)
  Future<List<Conversation>> getAllConversations({
    required String token,
    String? name,
  }) async {
    final res = await _service.getConversations(
      token: token,
      pageNumber: 1,
      pageSize: 1000, // giả sử max
      name: name,
    );

    if (res.data == null) return [];
    return res.data!.items;
  }

  Future<ConversationMessageListResponse> getMessages({
    required String token,
    required String conversationId,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final res = await _service.getConversationMessages(
      token: token,
      conversationId: conversationId,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    if (res.data == null) {
      return ConversationMessageListResponse(
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

  Future<Conversation?> getConversationById({
    required String token,
    required String conversationId,
  }) async {
    final res = await _service.getConversationById(
      token: token,
      conversationId: conversationId,
    );

    return res.data;
  }

  Future<Conversation?> getConversationByUser({
    required String token,
    required String userId,
  }) async {
    final res = await _service.getConversationByUser(
      token: token,
      userId: userId,
    );

    return res.data;
  }

  Future<TranslatedMessage?> translateMessage({
    required String token,
    required String messageId,
  }) async {
    final res = await _service.translateMessage(
      token: token,
      messageId: messageId,
    );

    return res.data;
  }

  Future<ConversationTranslationLanguage?> getTranslationLanguage({
    required String token,
    required String conversationId,
  }) async {
    final res = await _service.getTranslationLanguage(
      token: token,
      conversationId: conversationId,
    );

    return res.data;
  }

  Future<bool> updateTranslationLanguage({
    required String token,
    required String conversationId,
    required String languageCode,
  }) async {
    final res = await _service.updateTranslationLanguage(
      token: token,
      conversationId: conversationId,
      languageCode: languageCode,
    );

    return res.message != null && res.message!.contains("Success");
  }

  Future<ConversationImagesResponse?> getConversationImages({
    required String token,
    required String conversationId,
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    final res = await _service.getConversationImages(
      token: token,
      conversationId: conversationId,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    return res.data;
  }
}
