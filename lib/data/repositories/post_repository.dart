import '../models/api_response.dart';
import '../models/post/comment_model.dart';
import '../models/post/post_model.dart';
import '../models/post/react_model.dart';
import '../models/post/share_request_model.dart';
import '../models/post/update_comment_model.dart';
import '../models/post/update_post_model.dart';
import '../services/apis/post_service.dart';

class PostRepository {
  final PostService _service;

  PostRepository(this._service);

  Future<ApiResponse<PostPaginationResponse>> getAllPosts({
    required String token,
    int pageNumber = 1,
    int pageSize = 10,
    String? keyword,
  }) async {
    try {
      return await _service.getAllPosts(
        token: token,
        pageNumber: pageNumber,
        pageSize: pageSize,
        keyword: keyword,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<PostReactionResponse> react({
    required String token,
    required String postId,
    required String reactionType,
  }) async {
    return await _service.react(
      token: token,
      postId: postId,
      reactionType: reactionType,
    );
  }

  Future<PostReactionResponse> unReact({
    required String token,
    required String postId,
  }) async {
    return await _service.unReact(
      token: token,
      postId: postId,
    );
  }

  Future<ApiResponse<PostModel>> getPostDetail({
    required String token,
    required String postId,
  }) async {
    return await _service.getPostDetail(
      token: token,
      postId: postId,
    );
  }

  Future<ApiResponse<PostModel>> createPost({
    required String token,
    required String content,
    required List<String> imageUrls,
  }) async {
    try {
      return await _service.createPost(
        token: token,
        content: content,
        imageUrls: imageUrls,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<PostModel>> sharePost({
    required String token,
    required SharePostRequest request,
  }) async {
    try {
      return await _service.sharePost(token: token, request: request);
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<void>> deletePost({
    required String token,
    required String postId,
  }) async {
    try {
      return await _service.deletePost(
        token: token,
        postId: postId,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<CommentModel>> commentPost({
    required String token,
    required String postId,
    required CreateCommentRequest request,
  }) async {
    try {
      return await _service.commentPost(
        token: token,
        postId: postId,
        request: request,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<void>> deleteComment({
    required String token,
    required String commentId,
  }) async {
    try {
      return await _service.deleteComment(
        token: token,
        commentId: commentId,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<void>> updateComment({
    required String token,
    required String commentId,
    required UpdateCommentRequest request,
  }) async {
    try {
      return await _service.updateComment(
        token: token,
        commentId: commentId,
        request: request,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<void>> updatePost({
    required String token,
    required String postId,
    required UpdatePostRequest request,
  }) async {
    try {
      return await _service.updatePost(
        token: token,
        postId: postId,
        request: request,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<PostPaginationResponse>> getMyPosts({
    required String token,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      return await _service.getMyPosts(
        token: token,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
    } catch (e) {
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
      return await _service.getUserPosts(
        token: token,
        userId: userId,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
    } catch (e) {
      rethrow;
    }
  }
}
