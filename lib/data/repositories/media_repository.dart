import 'dart:io';
import '../models/media/upload_file_response.dart';
import '../models/api_response.dart';
import '../services/apis/media_service.dart';

class MediaRepository {
  final MediaService _service;

  MediaRepository(this._service);

  Future<ApiResponse<UploadFileResponse>> uploadFile(
      String token, File file,
      {bool addUniqueName = true}) async {
    try {
      return await _service.uploadFile(
        token: token,
        file: file,
        addUniqueName: addUniqueName,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<UploadFileResponse>> uploadAudio(
      String token, File file,
      {bool addUniqueName = true}) async {
    try {
      return await _service.uploadAudio(
        token: token,
        file: file,
        addUniqueName: addUniqueName,
      );
    } catch (e) {
      rethrow;
    }
  }
}
