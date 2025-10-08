import '../models/profile/profile_setup_request.dart';
import '../services/user_service.dart';

class UserRepository {
  final UserService _service;

  UserRepository(this._service);

  /// profile setup
  Future<void> profileSetup(String token, ProfileSetupRequest req) async {
    try {
      await _service.profileSetup(token, req);
    } catch (e) {
      throw Exception('Profile setup failed: $e');
    }
  }
}
