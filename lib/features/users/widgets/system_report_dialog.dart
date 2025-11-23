import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../core/api/api_client.dart';
import '../../../../data/repositories/media_repository.dart';
import '../../../../data/repositories/report_repository.dart';
import '../../../../data/services/apis/media_service.dart';
import '../../../../data/services/apis/report_service.dart';

class SystemReportDialog extends StatefulWidget {
  final VoidCallback? onSubmit;

  const SystemReportDialog({super.key, this.onSubmit});

  @override
  State<SystemReportDialog> createState() => _SystemReportDialogState();
}

class _SystemReportDialogState extends State<SystemReportDialog> {
  final TextEditingController _descriptionController = TextEditingController();
  String? _errorText;

  final List<String> reasons = [
    "Kháng cáo",
    "Lỗi hệ thống",
    "Lý do khác",
  ];

  late Map<String, bool> selected;
  final List<String> _imageUrls = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    selected = {for (var r in reasons) r: false};
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _imageUrls.addAll(pickedFiles.map((e) => e.path));
      });
    }
  }

  void _handleSubmit() async {
    final loc = AppLocalizations.of(context);
    final selectedReasons = selected.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selectedReasons.isEmpty) {
      setState(() => _errorText = loc.translate("select_reason_first"));
      return;
    }

    if (selected["Lý do khác"] == true &&
        _descriptionController.text.trim().isEmpty) {
      setState(() => _errorText = loc.translate("enter_other_reason"));
      return;
    }

    final reason = selectedReasons.map((r) {
      if (r == "Lý do khác") return _descriptionController.text.trim();
      return r;
    }).join(", ");

    final description = _descriptionController.text.trim();
    setState(() => _errorText = null);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if (token == null) throw Exception("Token missing");

      // Upload ảnh nếu có
      List<String> uploadedUrls = [];
      if (_imageUrls.isNotEmpty) {
        final mediaRepo = MediaRepository(MediaService(ApiClient()));
        final uploadRes = await mediaRepo.uploadImages(
          token,
          _imageUrls.map((p) => File(p)).toList(),
        );
        uploadedUrls = uploadRes.data?.urls ?? [];
      }

      final repo = ReportRepository(ReportService(ApiClient()));

      // Report type System, không cần check đã report
      await repo.postReport(
        token: token,
        reportType: "System",
        targetId: "", // không dùng id
        reason: reason,
        description: description,
        imageUrls: uploadedUrls,
      );

      Navigator.pop(context);
      widget.onSubmit?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate("report_submitted"))),
      );
    } catch (e) {
      setState(() {
        _errorText = loc.translate("report_failed");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final Gradient bg = isDark
        ? const LinearGradient(
      colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(colors: [Colors.white, Colors.white]);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 500),
        child: Container(
          decoration: BoxDecoration(
            gradient: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.translate("report"),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: textColor, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                /// Checkbox items
                ...reasons.map(
                      (r) => CheckboxListTile(
                    value: selected[r],
                    onChanged: (v) => setState(() => selected[r] = v ?? false),
                    title: Text(r, style: TextStyle(color: textColor)),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),

                if (_errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(_errorText!,
                        style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ),

                const SizedBox(height: 12),

                /// Description
                TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: loc.translate("report_description_placeholder"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 12),

                /// Image picker
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._imageUrls.map((path) {
                      return Stack(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              image: DecorationImage(
                                image: FileImage(File(path)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: -8,
                            right: -8,
                            child: IconButton(
                              icon: const Icon(Icons.cancel,
                                  size: 18, color: Colors.red),
                              onPressed: () =>
                                  setState(() => _imageUrls.remove(path)),
                            ),
                          )
                        ],
                      );
                    }),
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.add_a_photo, color: Colors.grey),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 16),

                /// Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(loc.translate("cancel")),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(loc.translate("submit"),
                          style: const TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
