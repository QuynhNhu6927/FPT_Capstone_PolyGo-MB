import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/transaction/wallet_info_response.dart';
import '../withdraw/withdraw_request.dart';

class MyWallet extends StatelessWidget {
  final double balance;
  final double pendingBalance;
  final bool balanceHidden;
  final VoidCallback toggleBalance;
  final VoidCallback onDeposit;
  final List<WalletAccount> accounts;

  const MyWallet({
    super.key,
    required this.balance,
    required this.pendingBalance,
    required this.balanceHidden,
    required this.toggleBalance,
    required this.onDeposit,
    required this.accounts,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final colorPrimary = const Color(0xFF2563EB);

    return Container(
      padding: EdgeInsets.all(sw(context, 16)),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)])
            : const LinearGradient(colors: [Colors.white, Colors.white]),
        borderRadius: BorderRadius.circular(sw(context, 16)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.translate("my_wallet"),
            style: t.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: st(context, 20),
                color: isDark ? Colors.white : Colors.black87),
          ),
          SizedBox(height: sh(context, 16)),
          Container(
            padding: EdgeInsets.all(sw(context, 16)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [colorPrimary, colorPrimary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(sw(context, 12)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.translate("balance"),
                          style: t.bodyMedium?.copyWith(color: Colors.white70, fontSize: st(context, 14)),
                        ),
                        SizedBox(height: sh(context, 4)),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: balanceHidden
                                    ? "****"
                                    : balance
                                    .toString()
                                    .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => "${m[1]}."),
                                style: t.headlineSmall?.copyWith(
                                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: st(context, 24)),
                              ),
                              TextSpan(
                                text: " đ",
                                style: t.headlineSmall?.copyWith(
                                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: st(context, 16)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: toggleBalance,
                      icon: Icon(balanceHidden ? Icons.visibility_off : Icons.visibility, color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: sh(context, 8)),
                Text(
                  "${loc.translate("pending_balance")}: ${balanceHidden ? "****" : pendingBalance.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => "${m[1]}.")} đ",
                  style: t.bodyMedium?.copyWith(color: Colors.white70, fontSize: st(context, 14)),
                ),
                SizedBox(height: sh(context, 16)),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onDeposit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: colorPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(sw(context, 8))),
                        ),
                        child: Text(loc.translate("add_balance")),
                      ),
                    ),
                    SizedBox(width: sw(context, 12)),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WithdrawRequest(accounts: accounts),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: colorPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sw(context, 8)),
                          ),
                        ),
                        child: Text(loc.translate("withdraw")),
                      ),
                    ),

                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.2, end: 0);
  }
}
