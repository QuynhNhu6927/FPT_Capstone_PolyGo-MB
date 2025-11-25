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

class ReportUserDialog extends StatefulWidget {
  final String userId;
  final VoidCallback? onSubmit;

  const ReportUserDialog({super.key, required this.userId, this.onSubmit});

  @override
  State<ReportUserDialog> createState() => _ReportUserDialogState();
}

class _ReportUserDialogState extends State<ReportUserDialog> {
  final TextEditingController _descriptionController = TextEditingController();
  String? _errorText;
  bool _isSubmitting = false;
  final List<String> reasons = [
    "report_fake",
    "report_spam",
    "report_negative",
    "report_illegal",
    "report_other",
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

    if (selected["report_other"] == true &&
        _descriptionController.text.trim().isEmpty) {
      setState(() => _errorText = loc.translate("enter_other_reason"));
      return;
    }

    final reason = selectedReasons
        .map((r) {
      if (r == "report_other") return _descriptionController.text.trim();
      return loc.translate(r);
    })
        .join(", ");

    final description = _descriptionController.text.trim();

    setState(() {
      _errorText = null;
      _isSubmitting = true;
    });

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

      final res = await repo.postReport(
        token: token,
        reportType: "User",
        targetId: widget.userId,
        reason: reason,
        description: description,
        imageUrls: uploadedUrls,
      );

      if (res != null && res.status != null) {
        Navigator.pop(context);
        widget.onSubmit?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate("report_submitted"))),
        );
      } else {
        setState(() {
          _errorText =
              loc.translate("already_report_user");
        });
      }
    } catch (e) {
      setState(() {
        _errorText = loc.translate("report_failed");
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
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
                Center(
                  child: Text(
                    loc.translate("report"),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ---- DIVIDER ----
                Divider(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  thickness: 1,
                ),

                const SizedBox(height: 10),

                ...reasons.map(
                  (r) => CheckboxListTile(
                    value: selected[r],
                    onChanged: (v) => setState(() => selected[r] = v ?? false),
                    title: Text(loc.translate(r), style: TextStyle(color: textColor)),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),

                if (_errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),

                const SizedBox(height: 12),

                TextField(
                  controller: _descriptionController,
                  maxLines: 2,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: loc.translate("report_description_placeholder"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

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
                              icon: const Icon(
                                Icons.cancel,
                                size: 18,
                                color: Colors.red,
                              ),
                              onPressed: () =>
                                  setState(() => _imageUrls.remove(path)),
                            ),
                          ),
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
                        child: const Icon(
                          Icons.add_a_photo,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(loc.translate("cancel")),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        loc.translate("submit"),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
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
