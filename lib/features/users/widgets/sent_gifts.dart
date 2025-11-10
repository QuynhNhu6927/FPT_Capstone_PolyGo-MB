import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_client.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/gift/gift_present_request.dart';
import '../../../data/models/gift/gift_present_response.dart';
import '../../../data/repositories/gift_repository.dart';
import '../../../data/services/apis/gift_service.dart';
import '../../rating/widgets/inven_gifts.dart';

class SentGiftsDialog extends StatefulWidget {
  final String receiverId;

  const SentGiftsDialog({super.key, required this.receiverId});

  @override
  State<SentGiftsDialog> createState() => _SentGiftsDialogState();
}

class _SentGiftsDialogState extends State<SentGiftsDialog> {
  late final GiftRepository _repo;
  String? _selectedGiftId;
  String? _selectedGiftName;
  int _quantity = 1;
  bool _isAnonymous = false;
  final TextEditingController _messageCtrl = TextEditingController();
  bool _sending = false;
  GiftPresentResponse? _result;

  @override
  void initState() {
    super.initState();
    _repo = GiftRepository(GiftService(ApiClient()));
  }

  Future<void> _selectGift() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const InvenGifts(),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedGiftId = result['giftId'];
        _selectedGiftName = result['giftName'];
        _quantity = result['quantity'] ?? 1;
      });
    }
  }

  Future<void> _sendGift() async {
    if (_selectedGiftId == null) return;
    setState(() => _sending = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final req = GiftPresentRequest(
        receiverId: widget.receiverId,
        giftId: _selectedGiftId!,
        quantity: _quantity,
        message: _messageCtrl.text,
        isAnonymous: _isAnonymous,
      );

      final res = await _repo.presentGift(token: token, request: req);

      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ ${res?.giftName} sent successfully!"),
          duration: const Duration(seconds: 2),
        ),
      );

      setState(() {
        _sending = false;
      });
    } catch (e) {
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to send gift: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.translate("send_gift"),
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectGift,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _selectedGiftName != null ? '$_selectedGiftName x $_quantity' : loc.translate("choose_gift"),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Message field
              TextField(
                controller: _messageCtrl,
                decoration: InputDecoration(
                  labelText: loc.translate("message_optional"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Switch(
                    value: _isAnonymous,
                    onChanged: (v) => setState(() => _isAnonymous = v),
                  ),
                  Text(
                    loc.translate("send_anonymously"),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Send button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sending || _selectedGiftId == null ? null : _sendGift,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _sending
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : Text(
                    loc.translate("send"),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Result section
              if (_result != null) ...[
                Divider(thickness: 1, color: Colors.grey.shade300),
                const SizedBox(height: 8),
                Text(
                  loc.translate("gift_sent_success"),
                  style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildResultRow("Gift", _result!.giftName),
                _buildResultRow("Receiver", _result!.receiverName),
                _buildResultRow("Quantity", _result!.quantity.toString()),
                _buildResultRow("Anonymous", _result!.isAnonymous ? "Yes" : "No"),
                if (_result!.message?.isNotEmpty ?? false)
                  _buildResultRow("Message", _result!.message ?? ''),
              ].animate().fadeIn(duration: 250.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 5,
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
