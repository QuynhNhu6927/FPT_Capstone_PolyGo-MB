import '../models/user/profile_setup_request.dart';
import '../models/user/update_profile_request.dart';
import '../models/user/update_userinfo_request.dart';
import '../models/user/user_all_response.dart';
import '../models/user/user_by_id_response.dart';
import '../models/user/user_matching_response.dart';
import '../services/apis/user_service.dart';

class UserRepository {
  final UserService _service;

  UserRepository(this._service);

  /// profile setup
  Future<void> profileSetup(String token, ProfileSetupRequest req) async {
    try {
      await _service.profileSetup(token, req);
    } catch (e) {
      // throw Exception('Profile setup failed: $e');
    }
  }

  Future<void> updateProfile(String token, UpdateProfileRequest req) async {
    try {
      await _service.updateProfile(token: token, req: req);
    } catch (e) {
      // throw Exception('Update profile failed: $e');
    }
  }

  Future<void> updateUserInfo(String token, UpdateInfoRequest req) async {
    try {
      await _service.updateUserInfo(token: token, req: req);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserMatchingItem>> getMatchingUsers(String token, {String lang = 'vi'}) async {
    final response = await _service.getMatchingUsers(token, lang: lang);
    return response.data?.items ?? [];
  }

  Future<List<UserItem>> getAllUsers(
      String token, {
        String lang = 'en',
        int pageNumber = 1,
        int pageSize = 20,
        String? name,
      }) async {
    final response = await _service.getAllUsers(
      token,
      lang: lang,
      pageNumber: pageNumber,
      pageSize: pageSize,
      name: name,
    );

    return response.data?.items ?? [];
  }

  Future<UserByIdResponse?> getUserById(String token, String id, {String lang = 'en'}) async {
    final response = await _service.getUserById(token, id, lang: lang);
    return response.data;
  }

}


