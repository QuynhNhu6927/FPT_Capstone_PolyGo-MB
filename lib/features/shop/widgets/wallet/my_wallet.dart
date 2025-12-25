import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/transaction/wallet_info_response.dart';
import '../withdraw/withdraw_request.dart';

class MyWallet extends StatefulWidget {
  final double balance;
  final double pendingBalance;
  final bool balanceHidden;
  final VoidCallback toggleBalance;
  final VoidCallback onDeposit;
  final List<WalletAccount> accounts;

  final double totalDeposited;
  final double totalSpent;
  final double totalEarned;
  final double totalWithdrawn;

  const MyWallet({
    super.key,
    required this.balance,
    required this.pendingBalance,
    required this.balanceHidden,
    required this.toggleBalance,
    required this.onDeposit,
    required this.accounts,
    required this.totalDeposited,
    required this.totalSpent,
    required this.totalEarned,
    required this.totalWithdrawn,
  });

  @override
  State<MyWallet> createState() => _MyWalletState();
}

class _MyWalletState extends State<MyWallet> {
  bool _showStats = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final colorPrimary = const Color(0xFF2563EB);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(sw(context, 16)),
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
                  )
                : const LinearGradient(colors: [Colors.white, Colors.white]),
            borderRadius: BorderRadius.circular(sw(context, 16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.translate("my_wallet"),
                style: t.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: st(context, 20),
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: sh(context, 16)),

              // Balance Panel
              Container(
                padding: EdgeInsets.all(sw(context, 16)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorPrimary, colorPrimary.withOpacity(0.85)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(sw(context, 12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.translate("balance"),
                              style: t.bodyMedium?.copyWith(
                                color: Colors.white70,
                                fontSize: st(context, 14),
                              ),
                            ),
                            SizedBox(height: sh(context, 4)),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: widget.balanceHidden
                                        ? "****"
                                        : formatCurrency(widget.balance),
                                    style: t.headlineSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: st(context, 20),
                                    ),
                                  ),
                                  TextSpan(
                                    text: " đ",
                                    style: t.headlineSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: st(context, 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: widget.toggleBalance,
                          icon: Icon(
                            widget.balanceHidden
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: sh(context, 8)),
                    Text(
                      "${loc.translate("pending_balance")}: "
                          "${widget.balanceHidden ? "****" :
                      formatCurrency(widget.pendingBalance)} đ",
                      style: t.bodyMedium?.copyWith(
                        color: Colors.white70,
                        fontSize: st(context, 14),
                      ),
                    ),
                    SizedBox(height: sh(context, 16)),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: widget.onDeposit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: colorPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  sw(context, 8),
                                ),
                              ),
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
                                  builder: (_) => WithdrawRequest(
                                    accounts: widget.accounts,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: colorPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  sw(context, 8),
                                ),
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
        ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.2, end: 0),

        SizedBox(height: sh(context, 16)),

        // WALLET + STATISTICS TOGETHER
        Container(
          padding: EdgeInsets.all(sw(context, 16)),
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
                  )
                : const LinearGradient(colors: [Colors.white, Colors.white]),
            borderRadius: BorderRadius.circular(sw(context, 16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // BUTTON TOGGLE INSIDE CONTAINER
              InkWell(
                onTap: () => setState(() => _showStats = !_showStats),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _showStats
                          ? loc.translate("hide_statistics")
                          : loc.translate("show_statistics"),
                      style: TextStyle(
                        color: colorPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: st(context, 16),
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      _showStats ? Icons.expand_less : Icons.expand_more,
                      color: colorPrimary,
                    ),
                  ],
                ),
              ),

              SizedBox(height: sh(context, 12)),

              // Animated statistics
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: _showStats
                    ? Column(
                        key: const ValueKey("stats"),
                        children: [
                          Row(
                            children: [
                              _buildStatBox(
                                context,
                                title: loc.translate("total_deposited"),
                                value: widget.totalDeposited,
                                color: colorPrimary,
                              ),
                              SizedBox(width: sw(context, 12)),
                              _buildStatBox(
                                context,
                                title: loc.translate("total_spent"),
                                value: widget.totalSpent,
                                color: Colors.red,
                              ),
                            ],
                          ),
                          SizedBox(height: sh(context, 12)),
                          Row(
                            children: [
                              _buildStatBox(
                                context,
                                title: loc.translate("total_earned"),
                                value: widget.totalEarned,
                                color: Colors.green,
                              ),
                              SizedBox(width: sw(context, 12)),
                              _buildStatBox(
                                context,
                                title: loc.translate("total_withdrawn"),
                                value: widget.totalWithdrawn,
                                color: Colors.orange,
                              ),
                            ],
                          ),
                        ],
                      )
                    : const SizedBox(key: ValueKey("empty")),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.2, end: 0),
      ],
    );
  }
}

String formatCurrency(double number) {
  if (number % 1 == 0) {
    final formatter = NumberFormat.currency(
      locale: "de_DE",
      symbol: "",
      decimalDigits: 0,
    );
    return formatter.format(number).trim();
  } else {
    final formatter = NumberFormat.currency(
      locale: "de_DE",
      symbol: "",
      decimalDigits: 2,
    );
    return formatter.format(number).trim();
  }
}

Widget _buildStatBox(
  BuildContext context, {
  required String title,
  required double value,
  required Color color,
}) {
  final theme = Theme.of(context);
  final t = theme.textTheme;

  return Expanded(
    child: Container(
      padding: EdgeInsets.symmetric(
        vertical: sh(context, 12),
        horizontal: sw(context, 12),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(sw(context, 12)),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: t.bodyMedium?.copyWith(
              fontSize: st(context, 13),
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: sh(context, 4)),
          Text(
            "${formatCurrency(value)} đ",
            style: t.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: st(context, 18),
            ),
          ),
        ],
      ),
    ),
  );
}
