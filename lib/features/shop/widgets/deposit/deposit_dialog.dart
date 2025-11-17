// deposit_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:polygo_mobile/features/shop/widgets/deposit/payment_web_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/payment/deposit_model.dart';
import '../../../../data/repositories/payment_repository.dart';
import '../../../../data/services/apis/payment_service.dart';
import 'package:intl/intl.dart';

class DepositDialog extends StatefulWidget {
  final VoidCallback? onDepositSuccess;
  const DepositDialog({super.key, this.onDepositSuccess});

  @override
  State<DepositDialog> createState() => _DepositDialogState();
}

class _DepositDialogState extends State<DepositDialog> {
  final List<int> presetAmounts = [10000, 50000, 100000, 200000, 500000, 1000000];
  int? selectedAmount;
  final TextEditingController _customController = TextEditingController();

  bool showConfirm = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  String _formatNumber(String number) {
    number = number.replaceAll(".", "");
    final chars = number.split('').reversed.toList();
    final formatted = <String>[];
    for (int i = 0; i < chars.length; i++) {
      formatted.add(chars[i]);
      if ((i + 1) % 3 == 0 && i != chars.length - 1) formatted.add('.');
    }
    return formatted.reversed.join();
  }

  int get amount => selectedAmount ?? int.tryParse(_customController.text.replaceAll(".", "")) ?? 0;
  String? _errorText;
  void _nextStep() {
    final loc = AppLocalizations.of(context);
    if (amount < 5000 || amount > 2000000) {
      setState(() {
        _errorText = loc.translate("5k-2tr");
      });
      return;
    }
    setState(() {
      _errorText = null;
      showConfirm = true;
    });
  }

  void _backStep() {
    setState(() {
      showConfirm = false;
    });
  }

  Future<void> _confirmDeposit() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception("Token not found");

    final repository = PaymentRepository(PaymentService(ApiClient()));
    final request = DepositUrlRequest(
      amount: amount,
      returnUrl: "polygo://success",
      cancelUrl: "polygo://cancel",
    );

    final response = await repository.getDepositUrl(token: token, request: request);
    final depositUrl = response.data?.depositUrl;
    final orderCode = response.data?.orderCode;
    if (depositUrl == null || orderCode == null) throw Exception("Deposit URL null");

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentWebView(
          url: depositUrl,
          returnUrl: request.returnUrl,
          cancelUrl: request.cancelUrl,
          orderCode: orderCode,
          onPaymentSuccess: () {
            widget.onDepositSuccess?.call();
            final loc = AppLocalizations.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(loc.translate("add_balance_success"))),
            );
            Navigator.pop(context);
          },
          onPaymentCancel: () {
            Navigator.pop(context);
          },
        ),
      ),
    );

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return Stack(
      children: [
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: showConfirm
                ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.translate("confirm_deposit"),
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(
                  "${NumberFormat('#,###', 'vi_VN').format(amount)} đ",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _backStep,
                        child: Text(loc.translate("cancel")),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _confirmDeposit,
                        child: Text(loc.translate("confirm")),
                      ),
                    ),
                  ],
                ),
              ],
            )
                : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.translate("choose_add_amount"),
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  itemCount: presetAmounts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 3,
                  ),
                  itemBuilder: (context, index) {
                    final amt = presetAmounts[index];
                    final isSelected = selectedAmount == amt;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedAmount = amt;
                          _customController.clear();
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${amt.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => "${m[1]}.")} đ",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.blue.shade900 : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _customController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      String formatted = _formatNumber(newValue.text);
                      return TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    }),
                  ],
                  decoration: InputDecoration(
                    labelText: loc.translate("another_amount"),
                    hintText: loc.translate("input_amount"),
                    border: OutlineInputBorder(),
                    errorText: _errorText,
                  ),
                  onTap: () => setState(() {
                    selectedAmount = null;
                    _errorText = null;
                  }),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    child: Text(loc.translate("next")),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isLoading)
          Positioned.fill(
            child: AbsorbPointer(
              absorbing: true,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
      ],
    );
  }
}
