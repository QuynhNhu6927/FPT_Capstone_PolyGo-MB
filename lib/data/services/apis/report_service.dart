import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/api_constants.dart';
import '../../models/api_response.dart';
import '../../models/report/report_request.dart';
import '../../models/report/view_report_details.dart';
import '../../models/report/view_report_model.dart';

class ReportAlreadyExistsException implements Exception {
  final String message;
  ReportAlreadyExistsException([this.message = 'Report already exists']);
  @override
  String toString() => message;
}

class ReportService {
  final ApiClient apiClient;

  ReportService(this.apiClient);

  /// Post a report
  Future<ApiResponse<ReportResponse>> postReport({
    required String token,
    required ReportRequestModel request,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.postReport,
        data: request.toJson(),
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => ReportResponse.fromJson(json['data'] ?? {}),
      );
    } on DioError catch (e) {
      if (e.response != null &&
          e.response?.statusCode == 400 &&
          e.response?.data is Map<String, dynamic>) {
        final data = e.response!.data as Map<String, dynamic>;
        if (data['message'] == 'Error.ReportAlreadyExists') {
          throw ReportAlreadyExistsException();
        }
      }
      rethrow;
    }
  }

  Future<ViewReportsResponse> getMyReports({
    required String token,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final response = await apiClient.get(
      ApiConstants.viewReports,
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final json = response.data as Map<String, dynamic>;
    return ViewReportsResponse.fromJson(json);
  }

  Future<ViewReportModel> getReportDetail({
    required String token,
    required String reportId,
  }) async {
    final response = await apiClient.get(
      ApiConstants.viewReportDetail.replaceFirst('{reportId}', reportId),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final json = response.data as Map<String, dynamic>;
    return ViewReportModel.fromJson(json['data'] ?? {});
  }
}


