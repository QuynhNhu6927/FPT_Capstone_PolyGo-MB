import '../models/auth/change_password_request.dart';
import '../models/auth/me_response.dart';
import '../models/auth/register_request.dart';
import '../models/auth/login_request.dart';
import '../services/auth_service.dart';
import '../models/auth/reset_password_request.dart';

class AuthRepository {
  final AuthService _service;

  AuthRepository(this._service);

  Future<void> sendOtp({required String mail, required int verificationType}) async {
    try {
      await _service.sendOtp(mail: mail, verificationType: verificationType);
    } catch (e) {
      // throw Exception('Send OTP failed: $e');
    }
  }

  Future<void> register(RegisterRequest req) async {
    try {
      await _service.register(req);
    } catch (e) {
      // throw Exception('Register failed: $e');
    }
  }

  /// Login → trả về JWT token
  Future<String> login(LoginRequest req) async {
    final res = await _service.login(req);
    if (res.data == null)
      {
        // throw Exception(res.message ?? 'Login failed');
      }
    return res.data!;
  }

  /// Reset password
  Future<void> resetPassword(ResetPasswordRequest req) async {
    try {
      await _service.resetPassword(req);
    } catch (e) {
      // throw Exception('Reset password failed: $e');
    }
  }

  /// User info
  Future<MeResponse> me(String token) async {
    final res = await _service.me(token);
    if (res.data == null)
      {
        // throw Exception(res.message ?? 'Get user info failed');
      }
    return res.data!;
  }

  Future<void> changePassword(ChangePasswordRequest req, String token) async {
    try {
      await _service.changePassword(req, token);
    } catch (e) {
      // throw Exception('Change password failed: $e');
    }
  }
}
