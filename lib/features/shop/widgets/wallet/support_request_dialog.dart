import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/transaction/send_inquiry_model.dart';
import '../../../../data/repositories/transaction_repository.dart';
import '../../../../data/services/apis/transaction_service.dart';
import '../../../../core/api/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupportRequestDialog {
  static Future<bool?> show(
      BuildContext context, String transactionId, bool isInquiry) async {
    final TextEditingController _controller = TextEditingController();
    final loc = AppLocalizations.of(context);
    bool showImage = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              titlePadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(showImage ? loc.translate("image") : loc.translate("request_support")),
                  IconButton(
                    icon: Icon(
                        showImage ? Icons.arrow_back : Icons.arrow_forward),
                    onPressed: () {
                      setState(() {
                        showImage = !showImage;
                      });
                    },
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: showImage
                    ? Container(
                  height: 150,
                  color: Colors.grey.shade200,
                  child: const Center(
                      child: Text("Giao diện hình ảnh (chưa có gì)")),
                )
                    : isInquiry
                    ? Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    loc.translate("support_request_sent"),
                    style: TextStyle(fontSize: 16),
                  ),
                )
                    : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                    loc.translate("your_support_request")),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _controller,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: loc.translate("your_problem"),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, null),
                  child: Text(loc.translate("cancel")),
                ),
                if (!showImage && !isInquiry)
                  ElevatedButton(
                    onPressed: () async {
                      final content = _controller.text.trim();
                      if (content.isEmpty) return;

                      final prefs = await SharedPreferences.getInstance();
                      final token = prefs.getString('token');
                      if (token == null) {
                        Navigator.pop(ctx, false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Token không tồn tại!")),
                        );
                        return;
                      }

                      final repo = TransactionRepository(
                        TransactionService(ApiClient()),
                      );

                      final success = await repo.sendInquiry(
                        token: token,
                        transactionId: transactionId,
                        request: SendInquiryRequest(userNotes: content),
                      );

                      Navigator.pop(ctx, success);
                    },
                    child: Text(loc.translate("confirm")),
                  ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result
              ? loc.translate("support_request_success")
              : loc.translate("support_request_failed")),
        ),
      );
    }

    return result;
  }
}
