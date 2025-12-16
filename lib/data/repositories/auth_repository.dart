import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../models/auth/change_password_request.dart';
import '../models/auth/me_response.dart';
import '../models/auth/register_request.dart';
import '../models/auth/login_request.dart';
import '../services/apis/auth_service.dart';
import '../models/auth/reset_password_request.dart';

class AuthRepository {
  final AuthService _service;

  AuthRepository(this._service);

  /// Gửi OTP
  Future<void> sendOtp({required String mail, required int verificationType}) async {
    try {
      await _service.sendOtp(mail: mail, verificationType: verificationType);
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        final error = e.response!.data['message'] as String?;
        if (error == "Error.MailAlreadyExists") {
          throw Exception("mail_exists");
        }
      }
      rethrow;
    }
  }

  /// Đăng ký
  Future<void> register(RegisterRequest req) async {
    try {
      await _service.register(req);
    } on DioError catch (e) {
      if (e.response != null && e.response?.data != null) {
        final error = e.response!.data['message'] as String?;
        if (error == "Error.InvalidOtp") {
          throw Exception("invalid_otp");
        } else if (error == "Error.MailAlreadyExists") {
          throw Exception("mail_exists");
        }
      }
      rethrow;
    }
  }

  /// Login
  Future<String> login(LoginRequest req) async {
    final res = await _service.login(req);

    if (res.data == null) {
      throw res.message ?? 'Error.System';
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
      throw Exception('Change password failed: ${e.toString()}');
    }
  }

  Future<String> loginWithGoogle(String idToken) async {
    final res = await _service.loginWithGoogle(idToken);

    if (res.data == null) {
      throw res.message ?? 'Error.GoogleLoginFailed';
    }

    return res.data!;
  }

  Future<String> loginWithGoogleAccount() async {
    try {
      final idToken = await _service.getGoogleIdToken();

      debugPrint('🟢 Google idToken: ${idToken != null ? "OK" : "NULL"}');

      if (idToken == null) {
        throw 'Error.GoogleCanceled';
      }

      final res = await _service.loginWithGoogle(idToken);

      debugPrint('🟢 Backend response data: ${res.data}');
      debugPrint('🟢 Backend message: ${res.message}');

      if (res.data == null) {
        throw res.message ?? 'Error.GoogleLoginFailed';
      }

      return res.data!;
    } catch (e, s) {
      debugPrint('❌ loginWithGoogleAccount error: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }



}
