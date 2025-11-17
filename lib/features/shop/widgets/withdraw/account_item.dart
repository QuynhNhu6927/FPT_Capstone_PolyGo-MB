import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/transaction/wallet_info_response.dart';

class AccountItem extends StatelessWidget {
  final WalletAccount account;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const AccountItem({
    super.key,
    required this.account,
    required this.selected,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    final backgroundGradient = selected
        ? (isDark
        ? const LinearGradient(
      colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(
      colors: [Colors.blue, Colors.blueAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ))
        : (isDark
        ? const LinearGradient(
      colors: [Color(0xFF2C2C2C), Color(0xFF3A3A3A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(
      colors: [Colors.white, Colors.white],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ));

    String maskedBankNumber = account.bankNumber.length > 3
        ? '*' * (account.bankNumber.length - 3) +
        account.bankNumber.substring(account.bankNumber.length - 3)
        : account.bankNumber;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: backgroundGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
          border: selected ? Border.all(color: Colors.blue, width: 2) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.bankName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${account.accountName} • $maskedBankNumber',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: selected ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            // CHECK ICON
            if (selected)
              const Icon(Icons.check_circle, color: Colors.white),

            const SizedBox(width: 10),

            // DELETE ICON
            GestureDetector(
              onTap: () => _confirmDelete(context),
              child: Icon(
                CupertinoIcons.delete,
                color: selected ? Colors.white : Colors.redAccent,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.translate("delete_bankaccount")),
        content: Text(
            "${loc.translate("confirm_delete_account")} ${account.bankName} (${account.bankNumber})?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.translate("cancel")),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: Text(loc.translate("delete")),
          ),
        ],
      ),
    );
  }
}
