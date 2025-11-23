import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../data/models/subscription/subscription_cancel_request.dart';
import '../../../../data/models/subscription/subscription_current_response.dart';
import '../../../../data/repositories/subscription_repository.dart';
import '../../../../data/services/apis/subscription_service.dart';

class SubscriptionActions {
  final SubscriptionRepository repo;

  SubscriptionActions({SubscriptionRepository? repository})
      : repo = repository ?? SubscriptionRepository(SubscriptionService(ApiClient()));

  Future<void> showCancelDialog({
    required BuildContext context,
    required CurrentSubscription? currentSubscription,
    required VoidCallback onSuccess,
  }) async {
    if (currentSubscription == null) return;

    final loc = AppLocalizations.of(context);
    final reasons = [
      "Too expensive",
      "Not using enough",
      "Found an alternative",
      "Technical issues",
      "Lack of feature",
      "Other",
    ];

    // Track selected reasons
    final Map<String, bool> selected = {for (var r in reasons) r: false};
    final otherController = TextEditingController();
    String? errorText;

    await showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : Colors.black;
        final Gradient cardBackground = isDark
            ? const LinearGradient(
          colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : const LinearGradient(colors: [Colors.white, Colors.white]);

        return StatefulBuilder(
          builder: (context, setState) => Dialog(
            backgroundColor: Colors.transparent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 520,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: cardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.translate("cancel"),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        loc.translate("cancel_warning"),
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // List of reasons
                      ...reasons.map(
                            (reason) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CheckboxListTile(
                              value: selected[reason],
                              onChanged: (v) => setState(() => selected[reason] = v ?? false),
                              title: Text(reason, style: TextStyle(color: textColor)),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),
                            if (reason == "Other" && selected["Other"] == true)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: SizedBox(
                                  height: 100,
                                  child: TextField(
                                    controller: otherController,
                                    maxLines: 4,
                                    style: TextStyle(color: textColor),
                                    decoration: InputDecoration(
                                      hintText: loc.translate("enter_other_reason"),
                                      hintStyle: TextStyle(
                                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    keyboardType: TextInputType.multiline,
                                    textInputAction: TextInputAction.newline,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (errorText != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(errorText!, style: const TextStyle(color: Colors.red)),
                        ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(loc.translate("cancel")),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () async {
                                final selectedReasons = selected.entries
                                    .where((e) => e.value)
                                    .map((e) => e.key == "Other" ? otherController.text.trim() : e.key)
                                    .where((r) => r.isNotEmpty)
                                    .toList();

                                if (selectedReasons.isEmpty) {
                                  setState(() {
                                    errorText = loc.translate("select_reason_first");
                                  });
                                  return;
                                }

                                final prefs = await SharedPreferences.getInstance();
                                final token = prefs.getString('token');
                                if (token == null || token.isEmpty) return;

                                try {
                                  final request = SubscriptionCancelRequest(
                                    reason: selectedReasons.join(', '),
                                  );
                                  await repo.cancelSubscription(token: token, request: request);

                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(loc.translate("cancel_success")),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                    onSuccess();
                                  }
                                } catch (_) {
                                  if (context.mounted) {
                                    setState(() {
                                      errorText = loc.translate("cancel_failed");
                                    });
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              child: Text(
                                loc.translate("confirm"),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> showAutoRenewDialog({
    required BuildContext context,
    required CurrentSubscription? currentSubscription,
    required VoidCallback onSuccess,
  }) async {
    if (currentSubscription == null) return;

    final loc = AppLocalizations.of(context);
    bool autoRenew = currentSubscription.autoRenew;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : Colors.black;
        final Gradient cardBackground = isDark
            ? const LinearGradient(
          colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : const LinearGradient(colors: [Colors.white, Colors.white]);

        return StatefulBuilder(
          builder: (context, setState) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                gradient: cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    loc.translate("auto_renew"),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          loc.translate("enable_auto_renew"),
                          style: TextStyle(color: textColor),
                        ),
                      ),
                      Switch(
                        value: autoRenew,
                        onChanged: (v) => setState(() => autoRenew = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(loc.translate("cancel")),
                        ),
                        const SizedBox(width: 8),
                        AppButton(
                          text: loc.translate("save"),
                          onPressed: () => Navigator.of(context).pop(true),
                          size: ButtonSize.sm,
                          variant: ButtonVariant.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) return;

    try {
      await repo.updateAutoRenew(token: token, autoRenew: autoRenew);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.translate("update_enable_success")),
            duration: const Duration(seconds: 2),
          ),
        );
        onSuccess();
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.translate("update_enable_failed")),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
