
import '../models/report/report_request.dart';
import '../models/report/view_report_details.dart';
import '../models/report/view_report_model.dart';
import '../services/apis/report_service.dart';

class ReportRepository {
  final ReportService _service;

  ReportRepository(this._service);

  Future<ReportResponse?> postReport({
    required String token,
    required String reportType,
    required String targetId,
    required String reason,
    String description = '',
    List<String> imageUrls = const [],
  }) async {
    final request = ReportRequestModel(
      reportType: reportType,
      targetId: targetId,
      reason: reason,
      description: description,
      imageUrls: imageUrls,
    );

    try {
      final res = await _service.postReport(token: token, request: request);
      return res.data;
    } on ReportAlreadyExistsException {
      return null;
    }
  }

  Future<ViewReportsResponse> getMyReports({
    required String token,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    return _service.getMyReports(
      token: token,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  Future<ViewReportModel> getReportDetail({
    required String token,
    required String reportId,
  }) async {
    return _service.getReportDetail(
      token: token,
      reportId: reportId,
    );
  }
}
