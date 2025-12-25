import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../data/models/transaction/add_bank_request.dart';
import '../../../../data/models/transaction/wallet_info_response.dart';
import '../../../../data/repositories/transaction_repository.dart';

class AddBankDialog {
  final TransactionRepository transactionRepo;

  AddBankDialog({required this.transactionRepo});

  Future<Map<String, String>?> showBankSelectionDialog(BuildContext context) async {
    TextEditingController searchCtrl = TextEditingController();
    List<Map<String, dynamic>> banks = [];
    List<Map<String, dynamic>> filteredBanks = [];

    try {
      final res = await Uri.parse('https://api.vietqr.io/v2/banks');
      final response = await http.get(res);
      if (response.statusCode == 200) {
        final jsonMap = json.decode(response.body);
        if (jsonMap['data'] != null && jsonMap['data'] is List) {
          banks = List<Map<String, dynamic>>.from(jsonMap['data']);
          filteredBanks = banks;
        }
      }
    } catch (e) {
      print("Error fetching banks: $e");
    }

    return showDialog<Map<String, String>>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Scaffold(
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            elevation: 1,
            title: Text("Select Bank"),
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: searchCtrl,
                  decoration: InputDecoration(
                    hintText: "Search by name or code",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    final input = value.toLowerCase();
                    setState(() {
                      filteredBanks = banks.where((bank) {
                        final name = (bank['name'] ?? '').toString().toLowerCase();
                        final code = (bank['code'] ?? '').toString().toLowerCase();
                        return name.contains(input) || code.contains(input);
                      }).toList();
                    });
                  },
                ),
              ),
              Expanded(
                child: filteredBanks.isEmpty
                    ? Center(child: Text("No banks found"))
                    : ListView.builder(
                  itemCount: filteredBanks.length,
                  itemBuilder: (_, index) {
                    final bank = filteredBanks[index];
                    return ListTile(
                      leading: bank['logo'] != null
                          ? Image.network(bank['logo'], width: 40, height: 40)
                          : null,
                      title: Text(bank['name'] ?? ''),
                      subtitle: Text(bank['code'] ?? ''),
                      onTap: () {
                        Navigator.pop(context, {
                          'name': (bank['name'] ?? '').toString(),
                          'code': (bank['code'] ?? '').toString(),
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<WalletAccount?> show(BuildContext context) async {
    final bankCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final numberCtrl = TextEditingController();

    String? _addBankError;
    String? selectedBankName;
    String? selectedBankCode;

    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Gradient cardBackground = isDark
        ? const LinearGradient(
      colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(colors: [Colors.white, Colors.white]);

    return showDialog<WalletAccount>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: Container(
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
                  // Tiêu đề
                  Text(
                    loc.translate("add_bank_account"),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Thông báo info
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            loc.translate("check_account_before_confirm"),
                            style: TextStyle(
                              color: Colors.orange.shade900,
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Chọn ngân hàng
                  InkWell(
                    onTap: () async {
                      final bank = await showBankSelectionDialog(context);
                      if (bank != null) {
                        setState(() {
                          selectedBankName = bank['name'];
                          selectedBankCode = bank['code'];
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              selectedBankName ?? loc.translate("select_bank"),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Tên tài khoản
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: loc.translate("account_name"),
                      border: const OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Số tài khoản
                  TextField(
                    controller: numberCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: loc.translate("bank_number"),
                      border: const OutlineInputBorder(),
                    ),
                  ),

                  if (_addBankError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _addBankError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  const SizedBox(height: 16),

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
                          text: loc.translate("add"),
                          onPressed: () async {
                            final bankName = selectedBankName;
                            final accountName = nameCtrl.text.trim();
                            final bankNumber = numberCtrl.text.trim();

                            if (bankName == null || bankName.isEmpty || accountName.isEmpty || bankNumber.isEmpty) {
                              setState(() {
                                _addBankError = loc.translate("please_fill_full");
                              });
                              return;
                            }

                            final prefs = await SharedPreferences.getInstance();
                            final token = prefs.getString('token');
                            if (token == null || token.isEmpty) return;

                            final success = await transactionRepo.addBankAccount(
                              token: token,
                              request: AddBankRequest(
                                bankName: bankName,
                                bankNumber: bankNumber,
                                accountName: accountName,
                              ),
                            );

                            if (!success) {
                              setState(() {
                                _addBankError = loc.translate("add_account_failed");
                              });
                              return;
                            }

                            Navigator.pop(
                              context,
                              WalletAccount(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                bankName: bankName,
                                accountName: accountName,
                                bankNumber: bankNumber,
                              ),
                            );
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
      ),
    );
  }

}
