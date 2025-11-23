import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/render_utils.dart';
import '../../../../data/models/report/view_report_details.dart';

class ReportDetailDialog extends StatelessWidget {
  final ViewReportModel report;
  final bool isDark;

  const ReportDetailDialog({
    super.key,
    required this.report,
    required this.isDark,
  });

  String formatDateTime(DateTime dt) => DateFormat('dd/MM/yyyy HH:mm').format(dt);

  Color statusColor(String? status) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final target = report.targetInfo;
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final secondaryText = isDark ? Colors.grey[400] : Colors.grey[600];

    List<Widget> buildContent() {
      List<Widget> children = [];

      Widget buildItem({required IconData icon, required String title, String? value, Color? valueColor}) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: secondaryText),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: textColor, fontSize: 14, height: 1.4),
                    children: [
                      TextSpan(text: "$title: ", style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (value != null)
                        TextSpan(
                          text: value,
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: valueColor ?? textColor,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }

      Widget buildMarkdownItem({required IconData icon, required String title, required String content}) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: secondaryText),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: 14 * 1.4 * 4 + 8, // khoảng 4 dòng
                  ),
                  child: SingleChildScrollView(
                    child: RenderUtils.selectableMarkdownText(
                      context,
                      content.isNotEmpty ? content : "No description",
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      switch (report.reportType?.toLowerCase()) {
        case 'system':
          if (report.reason != null) children.add(buildItem(icon: Icons.report, title: "Reason", value: report.reason));
          if (report.description != null && report.description!.isNotEmpty) {
            children.add(buildMarkdownItem(icon: Icons.description, title: "Description", content: report.description!));
          }
          if (report.status != null) children.add(buildItem(icon: Icons.info_outline, title: "Status", value: report.status, valueColor: statusColor(report.status)));
          if (report.createdAt != null) children.add(buildItem(icon: Icons.access_time, title: "Created At", value: formatDateTime(report.createdAt!)));
          break;

        case 'event':
          if (target?.title != null) children.add(buildItem(icon: Icons.event, title: "Title", value: target!.title!));
          if (target?.description != null && target!.description!.isNotEmpty) {
            children.add(buildMarkdownItem(icon: Icons.description, title: "Event Description", content: target.description!));
          }
          if (target?.status != null) children.add(buildItem(icon: Icons.info_outline, title: "Event Status", value: target?.status!, valueColor: statusColor(target?.status)));
          if (report.reason != null) children.add(buildItem(icon: Icons.report, title: "Reason", value: report.reason));
          if (report.description != null && report.description!.isNotEmpty) {
            children.add(buildMarkdownItem(icon: Icons.description, title: "Report Description", content: report.description!));
          }
          if (report.status != null) children.add(buildItem(icon: Icons.info_outline, title: "Report Status", value: report.status, valueColor: statusColor(report.status)));
          if (report.createdAt != null) children.add(buildItem(icon: Icons.access_time, title: "Created At", value: formatDateTime(report.createdAt!)));
          break;

        case 'post':
          if (target?.content != null) {
            children.add(buildMarkdownItem(icon: Icons.article, title: "Content", content: target!.content!));
          }
          if (target?.creator != null) children.add(buildItem(icon: Icons.person, title: "Creator", value: target?.creator!.name!));
          if (report.reason != null) children.add(buildItem(icon: Icons.report, title: "Reason", value: report.reason));
          if (report.description != null && report.description!.isNotEmpty) {
            children.add(buildMarkdownItem(icon: Icons.description, title: "Report Description", content: report.description!));
          }
          if (report.status != null) children.add(buildItem(icon: Icons.info_outline, title: "Report Status", value: report.status, valueColor: statusColor(report.status)));
          if (report.createdAt != null) children.add(buildItem(icon: Icons.access_time, title: "Created At", value: formatDateTime(report.createdAt!)));
          break;

        case 'user':
          if (target?.name != null) children.add(buildItem(icon: Icons.person, title: "User", value: target!.name!));
          if (report.reason != null) children.add(buildItem(icon: Icons.report, title: "Reason", value: report.reason));
          if (report.description != null && report.description!.isNotEmpty) {
            children.add(buildMarkdownItem(icon: Icons.description, title: "Report Description", content: report.description!));
          }
          if (report.status != null) children.add(buildItem(icon: Icons.info_outline, title: "Report Status", value: report.status, valueColor: statusColor(report.status)));
          if (report.createdAt != null) children.add(buildItem(icon: Icons.access_time, title: "Created At", value: formatDateTime(report.createdAt!)));
          break;

        default:
          children.add(const Text("No details available"));
      }

      // Images
      if (report.imageUrls != null && report.imageUrls!.isNotEmpty) {
        children.add(const SizedBox(height: 12));
        children.add(_buildImageGallery(context, report.imageUrls!));
      }

      return children;
    }

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    report.reportType ?? "Report Detail",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: isDark ? Colors.white70 : Colors.black54, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: buildContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery(BuildContext context, List<String> urls) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final url = urls[index];
          return GestureDetector(
            onTap: () => _showFullScreenGallery(context, urls, index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(url, width: 80, height: 80, fit: BoxFit.cover),
            ),
          );
        },
      ),
    );
  }

  void _showFullScreenGallery(BuildContext context, List<String> urls, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: urls.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                child: Center(
                  child: Image.network(urls[index], fit: BoxFit.contain),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
