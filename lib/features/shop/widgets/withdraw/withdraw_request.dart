import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../data/models/transaction/wallet_info_response.dart';
import '../../../../data/models/transaction/withdraw_confirm_request.dart';
import '../../../../data/models/transaction/withdraw_request_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/transaction_repository.dart';
import '../../../../data/services/apis/auth_service.dart';
import '../../../../data/services/apis/transaction_service.dart';
import 'account_item.dart';
import 'add_bank_dialog.dart';

class WithdrawRequest extends StatefulWidget {
  final List<WalletAccount> accounts;

  const WithdrawRequest({super.key, required this.accounts});

  @override
  State<WithdrawRequest> createState() => _WithdrawRequestState();
}

class _WithdrawRequestState extends State<WithdrawRequest> {
  int? selectedAccountIndex;
  late final TransactionRepository _transactionRepo;
  final List<int> presetAmounts = [50000, 100000, 200000, 500000, 1000000];
  int? selectedAmount;
  final TextEditingController _customAmountController = TextEditingController();
  String? _amountError;
  int withdrawTimes = 0;
  DateTime? nextWithdrawResetAt;

  @override
  void initState() {
    super.initState();
    _transactionRepo = TransactionRepository(TransactionService(ApiClient()));
    _loadUserInfo();
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  int get amount =>
      selectedAmount ??
      int.tryParse(_customAmountController.text.replaceAll(".", "")) ??
      0;

  void _validateAmount() {
    final loc = AppLocalizations.of(context);
    if (amount < 10000) {
      setState(() {
        _amountError = loc.translate("50k-10tr");
      });
    } else {
      setState(() {
        _amountError = null;
      });
    }
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) return;

    final repo = AuthRepository(AuthService(ApiClient()));
    final user = await repo.me(token);

    setState(() {
      withdrawTimes = user?.withdrawTimes ?? 0;
      nextWithdrawResetAt = user?.nextWithdrawResetAt;
    });
  }

  void _onCreateRequest() async {
    final loc = AppLocalizations.of(context);
    _validateAmount();

    if (selectedAccountIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate("please_select_account"))),
      );
      return;
    }

    if (_amountError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_amountError!)),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) return;

    final account = widget.accounts[selectedAccountIndex!];

    // Lấy balance từ API
    final walletInfo = await _transactionRepo.getWalletInfo(token: token);
    final availableBalance = walletInfo?.balance ?? 0;

    if (amount > availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate("withdraw_amount_exceeds_balance"))),
      );
      return;
    }

    final request = WithdrawRequestModel(
      amount: amount,
      bankName: account.bankName,
      bankNumber: account.bankNumber,
      accountName: account.accountName,
    );

    // Hiển thị loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final success = await _transactionRepo.createWithdrawRequest(
      token: token,
      request: request,
    );

    Navigator.pop(context); // ẩn loading

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate("out_of_withdraw"))),
      );
      return;
    }

    // Hiển thị dialog OTP
    _showOtpDialog(token);
  }

  void _showOtpDialog(String token) {
    final otpController = TextEditingController();
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Gradient cho background dialog
    final Gradient cardBackground = isDark
        ? const LinearGradient(
      colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(colors: [Colors.white, Colors.white]);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.transparent, // để hiển thị gradient
          contentPadding: EdgeInsets.zero,
          content: Container(
            decoration: BoxDecoration(
              gradient: cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tiêu đề
                Text(
                  loc.translate("otp_confirm"),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                // Nội dung cảnh báo
                Text(
                  loc.translate("otp_warning"),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                // Input OTP
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: loc.translate("otp"),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Nút
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: isDark ? Colors.white : Colors.black,
                      ),
                      child: Text(loc.translate("cancel")),
                    ),
                    const SizedBox(width: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: AppButton(
                        text: loc.translate("confirm"),
                        onPressed: () async {
                          final otp = otpController.text.trim();
                          if (otp.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(loc.translate("otp_required"))),
                            );
                            return;
                          }

                          // Hiển thị loading
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                          );

                          final confirmSuccess = await _transactionRepo.confirmWithdrawal(
                            token: token,
                            request: WithdrawConfirmRequest(otp: otp),
                          );

                          Navigator.pop(context);
                          Navigator.pop(context);

                          if (confirmSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(loc.translate("success_withdraw_request"))),
                            );
                            setState(() {
                              selectedAmount = null;
                              _customAmountController.clear();
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(loc.translate("otp_failed"))),
                            );
                          }
                        },
                        size: ButtonSize.sm,
                        variant: ButtonVariant.primary,
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

  Future<void> _reloadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) return;

    final res = await _transactionRepo.getWalletInfo(token: token);
    if (res != null) {
      setState(() {
        widget.accounts
          ..clear()
          ..addAll(res.accounts);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = widget.accounts;
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final colorPrimary = const Color(0xFF2563EB);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate("withdraw_request")),
        centerTitle: true,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              loc.translate("select_account"),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            if (accounts.isEmpty)
              ElevatedButton.icon(
                onPressed: () async {
                  final newAcc = await AddBankDialog(transactionRepo: _transactionRepo).show(context);
                  if (newAcc != null) {
                    await _reloadAccounts();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc.translate("add_bankaccount_success"))),
                    );
                  }
                },
                icon: const Icon(Icons.add),
                label: Text(loc.translate("add_bank_account")),
              )
            else
              Column(
                children: [
                  ...List.generate(accounts.length, (index) {
                    final acc = accounts[index];
                    return AccountItem(
                      account: acc,
                      selected: selectedAccountIndex == index,
                      isDark: Theme.of(context).brightness == Brightness.dark,
                      onTap: () => setState(() => selectedAccountIndex = index),
                      onDelete: () async {
                        final accId = acc.id;

                        // Hiển thị loading
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(child: CircularProgressIndicator()),
                        );

                        final prefs = await SharedPreferences.getInstance();
                        final token = prefs.getString('token');
                        if (token == null || token.isEmpty) return;
                        final success = await _transactionRepo.deleteBankAccount(
                          token: token,
                          bankAccountId: accId,
                        );

                        Navigator.pop(context);

                        if (!success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(loc.translate("delete_bankaccount_failed"))),
                          );
                          return;
                        }
                        setState(() {
                          widget.accounts.removeWhere((a) => a.id == accId);

                          if (selectedAccountIndex != null &&
                              selectedAccountIndex! >= widget.accounts.length) {
                            selectedAccountIndex = null;
                          }
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(loc.translate("bankaccount_deleted"))),
                        );
                      },


                    );
                  }),

                  if (accounts.length < 2)
                    ElevatedButton.icon(
                      onPressed: () async {
                        final newAcc = await AddBankDialog(transactionRepo: _transactionRepo).show(context);
                        if (newAcc != null) {
                          await _reloadAccounts();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(loc.translate("add_bankaccount_success"))),
                          );
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: Text(loc.translate("add_bank_account")),
                    ),
                ],
              ),
            const SizedBox(height: 24),

            Text(
              loc.translate("withdraw_amount"),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 10),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
                      _customAmountController.clear();
                      _amountError = null;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${amt.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => "${m[1]}.")} đ",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.blue.shade900
                            : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _customAmountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                TextInputFormatter.withFunction((oldValue, newValue) {
                  String number = newValue.text.replaceAll(".", "");
                  final chars = number.split('').reversed.toList();
                  final formatted = <String>[];
                  for (int i = 0; i < chars.length; i++) {
                    formatted.add(chars[i]);
                    if ((i + 1) % 3 == 0 && i != chars.length - 1)
                      formatted.add('.');
                  }
                  return TextEditingValue(
                    text: formatted.reversed.join(),
                    selection: TextSelection.collapsed(
                      offset: formatted.length,
                    ),
                  );
                }),
              ],
              decoration: InputDecoration(
                labelText: loc.translate("other_amount"),
                hintText: loc.translate("input_amount"),
                border: const OutlineInputBorder(),
                errorText: _amountError,
              ),
              onTap: () {
                setState(() {
                  selectedAmount = null;
                  _amountError = null;
                });
              },
              onChanged: (_) => _validateAmount(),
            ),

            const SizedBox(height: 30),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: withdrawTimes > 0 ? _onCreateRequest : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: withdrawTimes > 0 ? colorPrimary : Colors.grey,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  withdrawTimes > 0
                      ? loc.translate("create_withdraw_request")
                      : loc.translate("withdraw_time_out"),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (nextWithdrawResetAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "${loc.translate("withdraw_time_reset_at")} ${nextWithdrawResetAt!.toLocal().toString().substring(0, 16)}",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
