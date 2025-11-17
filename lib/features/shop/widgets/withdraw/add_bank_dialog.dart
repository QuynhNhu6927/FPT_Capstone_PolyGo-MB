import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/transaction/add_bank_request.dart';
import '../../../../data/models/transaction/wallet_info_response.dart';
import '../../../../data/repositories/transaction_repository.dart';

class AddBankDialog {
  final TransactionRepository transactionRepo;

  AddBankDialog({required this.transactionRepo});

  Future<WalletAccount?> show(BuildContext context) async {
    final bankCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final numberCtrl = TextEditingController();
    String? _addBankError;
    final loc = AppLocalizations.of(context);
    return showDialog<WalletAccount>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(loc.translate(
            "add_bank_account"),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                TextField(
                  controller: bankCtrl,
                  decoration: InputDecoration(
                    labelText: loc.translate("bank_name"),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: loc.translate("account_name"),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: numberCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: loc.translate("bank_number"),
                    border: OutlineInputBorder(),
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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.translate("cancel")),
            ),
            ElevatedButton(
              onPressed: () async {
                final bankName = bankCtrl.text.trim();
                final accountName = nameCtrl.text.trim();
                final bankNumber = numberCtrl.text.trim();

                if (bankName.isEmpty || accountName.isEmpty || bankNumber.isEmpty) {
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
              child: Text(loc.translate("add")),
            )
          ],
        ),
      ),
    );
  }
}
