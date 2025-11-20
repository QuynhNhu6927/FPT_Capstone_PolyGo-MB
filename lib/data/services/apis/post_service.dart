import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/api_constants.dart';
import '../../models/api_response.dart';
import '../../models/post/comment_model.dart';
import '../../models/post/post_model.dart';
import '../../models/post/react_model.dart';
import '../../models/post/share_request_model.dart';
import '../../models/post/update_comment_model.dart';
import '../../models/post/update_post_model.dart';

class PostService {
  final ApiClient apiClient;

  PostService(this.apiClient);

  Future<ApiResponse<PostPaginationResponse>> getAllPosts({
    required String token,
    int pageNumber = 1,
    int pageSize = 10,
    String? keyword,
  }) async {
    try {
      final response = await apiClient.get(
        ApiConstants.allPosts,
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          if (keyword != null) 'keyword': keyword,
        },
        headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      );

      final json = response.data as Map<String, dynamic>;

      return ApiResponse.fromJson(
        json,
        (data) => PostPaginationResponse.fromJson(data),
      );
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<PostPaginationResponse>(
          data: null,
          message: e.response?.data['message'] ?? e.message,
          statusCode: e.response?.statusCode,
        );
      }
      rethrow;
    }
  }

  Future<ApiResponse<PostModel>> sharePost({
    required String token,
    required SharePostRequest request,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.sharePosts,
        data: request.toJson(),
        headers: {
          ApiConstants.headerAuthorization: "Bearer $token",
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
        },
      );

      final json = response.data as Map<String, dynamic>;
      final post = PostModel.fromJson(json['data']);

      return ApiResponse(
        data: post,
        message: json['message'] ?? 'Success',
        statusCode: response.statusCode,
      );
    } on DioError catch (e) {
      return ApiResponse<PostModel>(
        data: null,
        message: e.response?.data['message'] ?? e.message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<PostReactionResponse> react({
    required String token,
    required String postId,
    required String reactionType,
  }) async {
    final url = ApiConstants.reactPost.replaceFirst('{postId}', postId);

    final response = await apiClient.post(
      url,
      data: PostReactionRequest(reactionType: reactionType).toJson(),
      headers: {
        ApiConstants.headerAuthorization: 'Bearer $token',
        ApiConstants.headerContentType: ApiConstants.contentTypeJson,
      },
    );

    return PostReactionResponse.fromJson(response.data);
  }

  Future<PostReactionResponse> unReact({
    required String token,
    required String postId,
  }) async {
    final url = ApiConstants.unReactPost.replaceFirst('{postId}', postId);

    final response = await apiClient.delete(
      url,
      headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
    );

    return PostReactionResponse.fromJson(response.data);
  }

  Future<ApiResponse<PostModel>> getPostDetail({
    required String token,
    required String postId,
  }) async {
    try {
      final url = ApiConstants.getPostDetail.replaceFirst("{postId}", postId);

      final response = await apiClient.get(
        url,
        headers: {ApiConstants.headerAuthorization: "Bearer $token"},
      );

      final json = response.data as Map<String, dynamic>;

      return ApiResponse.fromJson(json, (data) => PostModel.fromJson(data));
    } on DioError catch (e) {
      return ApiResponse<PostModel>(
        data: null,
        message: e.response?.data["message"] ?? e.message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ApiResponse<PostModel>> createPost({
    required String token,
    required String content,
    required List<String> imageUrls,
  }) async {
    try {
      final body = {'content': content, 'imageUrls': imageUrls};

      final response = await apiClient.post(
        ApiConstants.createPost,
        data: body,
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
        },
      );

      final json = response.data as Map<String, dynamic>;
      final post = PostModel.fromJson(json['data']);

      return ApiResponse(
        data: post,
        message: json['message'] ?? 'Success',
        statusCode: response.statusCode,
      );
    } on DioError catch (e) {
      return ApiResponse<PostModel>(
        data: null,
        message: e.response?.data['message'] ?? e.message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ApiResponse<void>> deletePost({
    required String token,
    required String postId,
  }) async {
    try {
      final url = ApiConstants.deletePost.replaceFirst('{postId}', postId);

      final response = await apiClient.delete(
        url,
        headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      );

      return ApiResponse<void>(
        data: null,
        message: response.data['message'] ?? 'Success',
        statusCode: response.statusCode,
      );
    } on DioError catch (e) {
      return ApiResponse<void>(
        data: null,
        message: e.response?.data['message'] ?? e.message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ApiResponse<CommentModel>> commentPost({
    required String token,
    required String postId,
    required CreateCommentRequest request,
  }) async {
    try {
      final url = ApiConstants.commentPost.replaceFirst('{postId}', postId);

      final response = await apiClient.post(
        url,
        data: request.toJson(),
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
        },
      );

      final json = response.data as Map<String, dynamic>;

      return ApiResponse.fromJson(
        json,
        (data) => CommentModel.fromJson(data as Map<String, dynamic>),
      );
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<CommentModel>(
          data: null,
          message: e.response?.data['message'] ?? e.message,
          statusCode: e.response?.statusCode,
        );
      }
      rethrow;
    }
  }

  Future<ApiResponse<void>> deleteComment({
    required String token,
    required String commentId,
  }) async {
    try {
      final url = ApiConstants.deleteCommentPost.replaceFirst(
        '{commentId}',
        commentId,
      );

      final response = await apiClient.delete(
        url,
        headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      );

      return ApiResponse<void>(
        data: null,
        message: response.data['message'] ?? 'Success',
        statusCode: response.statusCode,
      );
    } on DioError catch (e) {
      return ApiResponse<void>(
        data: null,
        message: e.response?.data['message'] ?? e.message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ApiResponse<void>> updateComment({
    required String token,
    required String commentId,
    required UpdateCommentRequest request,
  }) async {
    try {
      final url = ApiConstants.updateCommentPost.replaceFirst(
        '{commentId}',
        commentId,
      );

      final response = await apiClient.put(
        url,
        data: request.toJson(),
        headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      );

      return ApiResponse<void>(
        data: null,
        message: response.data['message'] ?? 'Success',
        statusCode: response.statusCode,
      );
    } on DioError catch (e) {
      return ApiResponse<void>(
        data: null,
        message: e.response?.data['message'] ?? e.message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ApiResponse<void>> updatePost({
    required String token,
    required String postId,
    required UpdatePostRequest request,
  }) async {
    try {
      final url = ApiConstants.updatePost.replaceFirst('{postId}', postId);

      final response = await apiClient.put(
        url,
        data: request.toJson(),
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
        },
      );

      return ApiResponse<void>(
        data: null,
        message: response.data['message'] ?? 'Success.Update',
        statusCode: response.statusCode,
      );
    } on DioError catch (e) {
      return ApiResponse<void>(
        data: null,
        message: e.response?.data['message'] ?? e.message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ApiResponse<PostPaginationResponse>> getMyPosts({
    required String token,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await apiClient.get(
        ApiConstants.myPost,
        queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize},
        headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      );

      final json = response.data as Map<String, dynamic>;

      return ApiResponse.fromJson(
        json,
        (data) => PostPaginationResponse.fromJson(data),
      );
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<PostPaginationResponse>(
          data: null,
          message: e.response?.data['message'] ?? e.message,
          statusCode: e.response?.statusCode,
        );
      }
      rethrow;
    }
  }

  Future<ApiResponse<PostPaginationResponse>> getUserPosts({
    required String token,
    required String userId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final url = ApiConstants.userPosts.replaceFirst('{userId}', userId);

      final response = await apiClient.get(
        url,
        queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize},
        headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      );

      final json = response.data as Map<String, dynamic>;

      return ApiResponse.fromJson(
        json,
        (data) => PostPaginationResponse.fromJson(data),
      );
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        return ApiResponse<PostPaginationResponse>(
          data: null,
          message: e.response?.data['message'] ?? e.message,
          statusCode: e.response?.statusCode,
        );
      }
      rethrow;
    }
  }
}
