import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/api/api_client.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../data/models/report/report_request.dart';
import '../../../../data/repositories/report_repository.dart';
import '../../../../data/services/apis/report_service.dart';
import 'report_detail_dialog.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  bool _loading = true;
  List<ReportResponse> _reports = [];
  String? _error;

  late final ReportRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = ReportRepository(ReportService(ApiClient()));
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) return;

      final res = await _repo.getMyReports(
        token: token,
        pageNumber: 1,
        pageSize: 20,
      );

      if (!mounted) return;
      setState(() {
        _reports = res.items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });

      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate("load_reports_error")),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String formatDateTime(DateTime dt) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.yMMMd(locale).add_Hm().format(dt.toLocal());
  }

  Color statusColor(String? status, bool isDark) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return isDark ? Colors.grey[400]! : Colors.grey;
      case 'processing':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'reject':
        return Colors.red;
      default:
        return isDark ? Colors.white70 : Colors.black87;
    }
  }

  Future<void> _showReportDetailDialog(String reportId, bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) return;

    try {
      final detail = await _repo.getReportDetail(token: token, reportId: reportId);

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => ReportDetailDialog(report: detail, isDark: isDark),
      );
    } catch (e) {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate("load_report_detail_error")),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.translate("my_reports")),
          centerTitle: true,
          backgroundColor: isDark ? Colors.black : Colors.white,
          foregroundColor: isDark ? Colors.white : Colors.black87,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _reports.isEmpty
            ? Center(
          child: Text(
            loc.translate("no_reports"),
            style: theme.textTheme.bodyMedium,
          ),
        )
            : ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: sw(context, 16),
            vertical: sh(context, 12),
          ),
          itemCount: _reports.length,
          itemBuilder: (context, index) {
            final report = _reports[index];

            return GestureDetector(
              onTap: () => _showReportDetailDialog(report.id!, isDark),
              child: Container(
                margin: EdgeInsets.only(bottom: sh(context, 10)),
                padding: EdgeInsets.all(sw(context, 16)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
                        : [Colors.white, Colors.white],
                  ),
                  borderRadius: BorderRadius.circular(sw(context, 12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${loc.translate("you_reported")} ${report.reportType} ${loc.translate("with_reason:")} ${report.reason}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: sh(context, 8)),
                    if (report.createdAt != null)
                      Text(
                        '${loc.translate("at")} ${formatDateTime(report.createdAt!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    SizedBox(height: sh(context, 12)),
                    Text(
                      '${loc.translate("status")}: ${report.status}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: statusColor(report.status, isDark),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
            );
          },
        ),
      ),
    );
  }
}
