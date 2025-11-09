import '../models/friends/friend_model.dart';
import '../models/friends/friend_request_model.dart';
import '../services/apis/friend_service.dart';

class FriendRepository {
  final FriendService _service;

  FriendRepository(this._service);

  Future<FriendRequestResponse?> sendFriendRequest(
      String token, String receiverId) async {
    final request = FriendRequestModel(receiverId: receiverId);
    final res = await _service.sendFriendRequest(token: token, request: request);
    return res.data;
  }

  Future<FriendRequestResponse?> cancelFriendRequest(
      String token, String receiverId) async {
    final res = await _service.cancelFriendRequest(token: token, receiverId: receiverId);
    return res.data;
  }

  Future<bool> acceptFriendRequest(String token, String senderId) async {
    final res = await _service.acceptFriendRequest(token: token, senderId: senderId);
    return res.message?.contains("Success") ?? false;
  }

  Future<bool> rejectFriendRequest(String token, String senderId) async {
    final res = await _service.rejectFriendRequest(token: token, senderId: senderId);
    return res.message?.contains("Success") ?? false;
  }

  Future<bool> unfriend(String token, String friendId) async {
    final res = await _service.unfriend(token: token, friendId: friendId);
    return res.message?.contains("Success") ?? false;
  }

  Future<List<FriendModel>> getAllFriends(
      String token, {
        int? pageNumber,
        int? pageSize,
        String? name,
        String? lang,
      }) async {
    final res = await _service.getAllFriends(
      token: token,
      pageNumber: pageNumber,
      pageSize: pageSize,
      name: name,
      lang: lang,
    );
    return res.data ?? [];
  }

  Future<List<FriendModel>> getAllRequest(
      String token, {
        int? pageNumber,
        int? pageSize,
        String? name,
        String? lang,
      }) async {
    final res = await _service.getAllRequest(
      token: token,
      pageNumber: pageNumber,
      pageSize: pageSize,
      name: name,
      lang: lang,
    );
    return res.data ?? [];
  }
}
