import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/api_constants.dart';
import '../../models/auth/change_password_request.dart';
import '../../models/auth/me_response.dart';
import '../../models/auth/register_request.dart';
import '../../models/auth/login_request.dart';
import '../../models/api_response.dart';
import '../../models/auth/reset_password_request.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final ApiClient apiClient;

  AuthService(this.apiClient);

  /// Gửi OTP
  Future<ApiResponse<void>> sendOtp({
    required String mail,
    required int verificationType,
  }) async {
    try {
      final url = '${ApiConstants.sendOtp}?mail=$mail&verificationType=$verificationType';
      final response = await apiClient.post(url);
      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(json, (_) => null);
    } on DioError catch (e) {
      if (e.response != null) {
        // print('Send OTP error response: ${e.response?.data}');
      }
      rethrow;
    }
  }

  /// Đăng ký
  Future<ApiResponse<void>> register(RegisterRequest req) async {
    try {
      final response = await apiClient.post(ApiConstants.register, data: req.toJson());
      return ApiResponse.fromJson(response.data as Map<String, dynamic>, (_) => null);
    } on DioError catch (e) {
      rethrow;
    }
  }

  /// Đăng nhập
  Future<ApiResponse<String>> login(LoginRequest req) async {
    try {
      final response = await apiClient.post(ApiConstants.login, data: req.toJson());
      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(json, (data) => data.toString());
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        final data = e.response!.data as Map<String, dynamic>;
        final message = data['message'] ?? 'Error.Unknown';
        return ApiResponse<String>(data: null, message: message);
      }

      final message = switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout => 'Error.Timeout',
        DioExceptionType.connectionError => 'Error.Network',
        _ => 'Error.System'
      };
      return ApiResponse<String>(data: null, message: message);
    } catch (e) {
      return ApiResponse<String>(data: null, message: 'Error.System');
    }

  }

  /// Reset password bằng mail + otp + password mới
  Future<ApiResponse<void>> resetPassword(ResetPasswordRequest req) async {
    try {
      final response = await apiClient.post(ApiConstants.resetPassword, data: req.toJson());
      return ApiResponse.fromJson(response.data as Map<String, dynamic>, (_) => null);
    } on DioError catch (e) {
      rethrow;
    }
  }

  /// User info
  Future<ApiResponse<MeResponse>> me(String token) async {
    try {
      final response = await apiClient.get(
        ApiConstants.me,
        headers: {ApiConstants.headerAuthorization: 'Bearer $token'},
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(json, (data) => MeResponse.fromJson(data));
    } on DioError catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<void>> changePassword(
      ChangePasswordRequest req, String token) async {
    try {
      final response = await apiClient.post(
        ApiConstants.changePassword,
        data: req.toJson(),
        headers: {
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
          ApiConstants.headerAuthorization: 'Bearer $token',
        },
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
            (_) => null,
      );
    } on DioError catch (e) {
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        final data = e.response!.data as Map<String, dynamic>;
        final msg = data['message'] ?? e.message;
        throw Exception(msg);
      } else {
        throw Exception(e.message);
      }
    }
  }

  /// Login bằng Google (idToken)
  Future<ApiResponse<String>> loginWithGoogle(String idToken) async {
    try {
      debugPrint('Sending Google idToken to backend');

      final response = await apiClient.post(
        ApiConstants.googleLogin,
        data: {'idToken': idToken},
      );

      debugPrint('API status: ${response.statusCode}');
      debugPrint('API data: ${response.data}');

      final json = response.data as Map<String, dynamic>;

      return ApiResponse.fromJson(
        json,
            (data) => data.toString(),
      );
    } on DioException catch (e, s) {
      debugPrint('API Google login error');
      debugPrint('Dio error: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      debugPrintStack(stackTrace: s);

      if (e.response?.data is Map<String, dynamic>) {
        final data = e.response!.data as Map<String, dynamic>;
        return ApiResponse<String>(
          data: null,
          message: data['message']?.toString() ?? 'Error.System',
        );
      }

      return ApiResponse<String>(
        data: null,
        message: 'Error.System',
      );
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: ApiConstants.androidId,
  );

  Future<String?> getGoogleIdToken() async {
    try {
      debugPrint('Google signIn start');

      await _googleSignIn.signOut();

      // await _googleSignIn.disconnect();

      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      final googleAuth = await googleUser.authentication;

      return googleAuth.idToken;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> googleSignOut() async {
    try {
      await _googleSignIn.signOut();
      debugPrint('Google signOut success');
    } catch (e) {
      //
    }
  }


}
