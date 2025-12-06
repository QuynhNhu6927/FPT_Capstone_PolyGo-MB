import 'package:flutter/material.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../data/repositories/event_repository.dart';

class HostCancelEventDialog extends StatefulWidget {
  final bool isHost;
  final String token;
  final String eventId;
  final EventRepository eventRepository;
  final BuildContext parentContext;
  final VoidCallback? onCancelSuccess;

  const HostCancelEventDialog({
    super.key,
    required this.isHost,
    required this.token,
    required this.eventId,
    required this.eventRepository,
    required this.parentContext,
    this.onCancelSuccess,
  });

  @override
  State<HostCancelEventDialog> createState() => _HostCancelEventDialogState();
}

class _HostCancelEventDialogState extends State<HostCancelEventDialog> {
  final TextEditingController _otherController = TextEditingController();
  String? _errorText;
  String? _generalError;

  late List<String> reasons;
  late Map<String, bool> selected;

  @override
  void initState() {
    super.initState();
    // reasons sẽ được build trong build() vì cần loc
    selected = {};
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  Future<void> _handleCancel() async {
    final loc = AppLocalizations.of(context);

    final selectedReasons = selected.entries
        .where((e) => e.value)
        .map(
          (e) => e.key == loc.translate("reason_other")
          ? _otherController.text.trim()
          : e.key,
    )
        .where((r) => r.isNotEmpty)
        .toList();

    if (selectedReasons.isEmpty) {
      setState(() {
        _errorText = loc.translate('select_reason_first');
        _generalError = null;
      });
      return;
    }

    try {
      final reason = selectedReasons.join(', ');

      final res = widget.isHost
          ? await widget.eventRepository.cancelEvent(
        token: widget.token,
        eventId: widget.eventId,
        reason: reason,
      )
          : await widget.eventRepository.unregisterEvent(
        token: widget.token,
        eventId: widget.eventId,
        reason: reason,
      );

      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(widget.parentContext, rootNavigator: true).pop();
      widget.onCancelSuccess?.call();

      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(
          content: Text(
            res?.message ??
                (widget.isHost
                    ? loc.translate('cancel_success')
                    : loc.translate('unregister_success')),
          ),
        ),
      );
    } catch (_) {
      setState(() {
        _generalError = loc.translate('cancel_too_late');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    // Build reasons từ localization
    reasons = [
      loc.translate("reason_busy"),
      loc.translate("reason_not_eligible"),
      loc.translate("reason_missing_info"),
      loc.translate("reason_other"),
    ];

    // Init selected nếu chưa có
    if (selected.isEmpty) {
      selected = {for (var r in reasons) r: false};
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    final Gradient cardBackground = isDark
        ? const LinearGradient(
      colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(colors: [Colors.white, Colors.white]);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 400),
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
                Center(
                  child: Text(
                    loc.translate('confirm_cancel'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Divider(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  thickness: 1,
                ),

                const SizedBox(height: 10),

                /// Lý do
                ...reasons.map(
                      (reason) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckboxListTile(
                        value: selected[reason],
                        onChanged: (v) =>
                            setState(() => selected[reason] = v ?? false),
                        title: Text(
                          reason,
                          style: TextStyle(color: textColor),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),

                      /// Input "Lý do khác"
                      if (reason == loc.translate("reason_other") &&
                          selected[reason] == true)
                        SizedBox(
                          height: 80,
                          child: TextField(
                            controller: _otherController,
                            maxLines: 3,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              hintText: loc.translate('enter_other_reason'),
                              hintStyle: TextStyle(
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[400],
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
                    ],
                  ),
                ),

                if (_errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _errorText!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                if (_generalError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _generalError!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),

                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(loc.translate('no')),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _handleCancel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          loc.translate('yes'),
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
    );
  }
}
