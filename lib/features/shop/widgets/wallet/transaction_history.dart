import 'package:flutter/material.dart';
import 'package:polygo_mobile/features/shop/widgets/wallet/support_request_dialog.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/transaction/wallet_transaction_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TransactionHistory extends StatelessWidget {
  final List<WalletTransaction> transactions;
  final bool balanceHidden;
  final double currentBalance;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final Function(int)? onPageChanged;
  final Function(String txId)? onInquirySuccess;

  const TransactionHistory({
    super.key,
    required this.transactions,
    required this.balanceHidden,
    required this.currentBalance,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
    this.onPageChanged,
    this.onInquirySuccess,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'expired':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

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
            loc.translate("transaction_history"),
            style: t.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: st(context, 20),
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: sh(context, 16)),
          if (transactions.isEmpty)
            Center(
              child: Text(
                loc.translate("no_transactions"),
                style: t.bodyMedium?.copyWith(color: Colors.grey),
              ),
            )
          else
            ...transactions.asMap().entries.map((entry) {
              final tx = entry.value;
              final color = tx.amount < 0 ? Colors.red : colorPrimary;
              final formattedAmount = tx.amount
                  .abs()
                  .toString()
                  .replaceAllMapped(
                    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                    (m) => "${m[1]}.",
                  );
              final amountText =
                  "${tx.amount < 0 ? '-' : '+'}$formattedAmount đ";

              // Tách ngày và giờ
              final dt = tx.createdAt.toLocal();
              final datePart =
                  "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
              final timePart =
                  "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}";

              return Padding(
                padding: EdgeInsets.only(bottom: sh(context, 12)),
                child: InkWell(
                  onTap: () async {
                    final success = await SupportRequestDialog.show(
                      context,
                      tx.id,
                      tx.isInquiry,
                    );

                    if (success == true) {
                      onInquirySuccess?.call(tx.id);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(sw(context, 12)),
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? const LinearGradient(
                              colors: [Color(0xFF2C2C2C), Color(0xFF3A3A3A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [
                                Colors.grey.shade100,
                                Colors.grey.shade100,
                              ],
                            ),
                      borderRadius: BorderRadius.circular(sw(context, 12)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // LEFT SIDE
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      loc.translate(
                                        tx.transactionType.toLowerCase(),
                                      ),
                                      style: t.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                    SizedBox(width: sw(context, 6)),
                                    Text(
                                      loc.translate("from"),
                                      style: t.bodySmall?.copyWith(
                                        fontSize: st(context, 12),
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(width: sw(context, 4)),
                                    Text(
                                      loc.translate(
                                        tx.transactionMethod.toLowerCase(),
                                      ),
                                      style: t.bodySmall?.copyWith(
                                        fontSize: st(context, 12),
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: sh(context, 4)),
                                Text(
                                  datePart,
                                  style: t.bodySmall?.copyWith(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  timePart,
                                  style: t.bodySmall?.copyWith(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            // RIGHT SIDE
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  amountText,
                                  style: t.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                                SizedBox(height: sh(context, 4)),
                                Text(
                                  "${loc.translate("remaining_balance")}: ${balanceHidden ? "****" : tx.remainingBalance.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => "${m[1]}.")} đ",
                                  style: t.bodySmall?.copyWith(
                                    fontSize: st(context, 12),
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: sh(context, 2)),
                                Text(
                                  loc.translate(
                                    tx.transactionStatus.toLowerCase(),
                                  ),
                                  style: t.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _statusColor(tx.transactionStatus),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 350.ms, delay: (entry.key * 80).ms),
                ),
              );
            }).toList(),
          SizedBox(height: sh(context, 8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: hasPreviousPage
                    ? () => onPageChanged?.call(currentPage - 1)
                    : null,
                icon: const Icon(Icons.arrow_back_ios),
              ),
              Text(
                "$currentPage / $totalPages",
                style: t.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: hasNextPage
                    ? () => onPageChanged?.call(currentPage + 1)
                    : null,
                icon: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
