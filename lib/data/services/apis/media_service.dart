import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/api_constants.dart';
import '../../models/api_response.dart';
import '../../models/media/upload_file_response.dart';

class MediaService {
  final ApiClient apiClient;

  MediaService(this.apiClient);

  Future<ApiResponse<UploadFileResponse>> uploadFile({
    required String token,
    required File file,
    bool addUniqueName = true,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
      });

      final response = await apiClient.post(
        "${ApiConstants.uploadFile}?addUniqueName=$addUniqueName",
        data: formData,
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
          ApiConstants.headerContentType: 'multipart/form-data',
        },
      );

      dynamic jsonData = response.data;
      if (jsonData is String) {
        jsonData = jsonDecode(jsonData);
      }

      final Map<String, dynamic> dataMap =
      (jsonData['data'] is Map) ? jsonData['data'] : jsonData;

      final fileInfo = UploadFileResponse.fromJson(dataMap);

      return ApiResponse(
        data: fileInfo,
        message: jsonData['message'] ?? "Upload success",
        statusCode: response.statusCode,
      );
    } on DioError catch (e) {
      //
      rethrow;
    }
  }

  Future<ApiResponse<UploadFileResponse>> uploadAudio({
    required String token,
    required File file,
    bool addUniqueName = true,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
      });

      final response = await apiClient.post(
        "${ApiConstants.uploadAudio}?addUniqueName=$addUniqueName",
        data: formData,
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
          ApiConstants.headerContentType: 'multipart/form-data',
        },
      );

      dynamic jsonData = response.data;
      if (jsonData is String) {
        jsonData = jsonDecode(jsonData);
      }

      final Map<String, dynamic> dataMap =
      (jsonData['data'] is Map) ? jsonData['data'] : jsonData;

      final fileInfo = UploadFileResponse.fromJson(dataMap);

      return ApiResponse(
        data: fileInfo,
        message: jsonData['message'] ?? "Upload success",
        statusCode: response.statusCode,
      );
    } on DioError catch (e) {
      //
      rethrow;
    }
  }
}
