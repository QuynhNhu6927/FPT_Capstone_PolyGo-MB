import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_client.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/transaction/wallet_transaction_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/subscription_repository.dart';
import '../../../data/services/apis/auth_service.dart';
import '../../../data/services/apis/subscription_service.dart';
import '../../shared/app_error_state.dart';

class Wallet extends StatefulWidget {
  final bool isRetrying;
  final VoidCallback? onError;

  const Wallet({super.key, this.isRetrying = false, this.onError});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  bool _balanceHidden = true;
  double _balance = 0;
  List<WalletTransaction> _transactions = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant Wallet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRetrying && !oldWidget.isRetrying) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Future.wait([_loadBalance(), _loadTransactions()]);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
      widget.onError?.call();
    }
  }

  Future<void> _loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception("Token not found");

    try {
      final user = await AuthRepository(AuthService(ApiClient())).me(token);
      if (!mounted) return;
      setState(() {
        _balance = user.balance;
      });
    } catch (e) {
      throw Exception("Failed to load balance: $e");
    }
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception("Token not found");

    try {
      final repo = SubscriptionRepository(SubscriptionService(ApiClient()));
      final response = await repo.getWalletTransactions(
          token: token, pageNumber: 1, pageSize: 10);
      if (!mounted) return;
      setState(() {
        _transactions = response?.items ?? [];
        _loading = false;
      });
    } catch (e) {
      throw Exception("Failed to load transactions: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final colorPrimary = const Color(0xFF2563EB);

    final isTablet = MediaQuery.of(context).size.width >= 600;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: AppErrorState(onRetry: _loadData),
      );
    }

    Widget walletCard() {
      return Container(
        padding: EdgeInsets.all(sw(context, 16)),
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)])
              : const LinearGradient(colors: [Colors.white, Colors.white]),
          borderRadius: BorderRadius.circular(sw(context, 16)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // ← tự dãn theo nội dung
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
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: _balanceHidden
                                  ? "****"
                                  : "${_balance.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => "${m[1]}.")}",
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
                      IconButton(
                        onPressed: () => setState(() => _balanceHidden = !_balanceHidden),
                        icon: Icon(_balanceHidden ? Icons.visibility_off : Icons.visibility, color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: sh(context, 16)),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
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
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: colorPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(sw(context, 8))),
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

    Widget transactionsCard() {
      return Container(
        padding: EdgeInsets.all(sw(context, 16)),
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)])
              : const LinearGradient(colors: [Colors.white, Colors.white]),
          borderRadius: BorderRadius.circular(sw(context, 16)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.translate("transaction_history"),
              style: t.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold, fontSize: st(context, 20), color: isDark ? Colors.white : Colors.black87),
            ),
            SizedBox(height: sh(context, 16)),
            if (_transactions.isEmpty)
              Center(child: Text(loc.translate("no_transactions"), style: t.bodyMedium?.copyWith(color: Colors.grey)))
            else
              ..._transactions.asMap().entries.map((entry) {
                final tx = entry.value;
                final color = tx.amount < 0 ? Colors.red : colorPrimary;
                final formattedAmount = tx.amount
                    .abs()
                    .toString()
                    .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => "${m[1]}.");
                final amountText = "${tx.amount < 0 ? '-' : '+'}$formattedAmount đ";

                return Padding(
                  padding: EdgeInsets.only(bottom: sh(context, 12)),
                  child: Container(
                    padding: EdgeInsets.all(sw(context, 12)),
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? const LinearGradient(colors: [Color(0xFF2C2C2C), Color(0xFF3A3A3A)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight)
                          : LinearGradient(colors: [Colors.grey.shade100, Colors.grey.shade100]),
                      borderRadius: BorderRadius.circular(sw(context, 12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx.transactionType,
                                style: t.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                            SizedBox(height: sh(context, 4)),
                            Text(tx.createdAt.toLocal().toString().split(".").first,
                                style: t.bodySmall?.copyWith(
                                    color: isDark ? Colors.grey[400] : Colors.grey[700])),
                          ],
                        ),
                        Text(amountText,
                            style: t.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
                      ],
                    ),
                  ).animate().fadeIn(duration: 350.ms, delay: (entry.key * 80).ms),
                );
              }).toList(),
          ],
        ),
      );
    }

    if (isTablet) {
      return Padding(
        padding: EdgeInsets.all(sw(context, 16)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: walletCard()),
            SizedBox(width: sw(context, 16)),
            Expanded(flex: 3, child: transactionsCard()),
          ],
        ),
      );
    } else {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: sw(context, 16), vertical: sh(context, 16)),
          children: [
            walletCard(),
            SizedBox(height: sh(context, 24)),
            transactionsCard(),
          ],
        ),
      );
    }
  }
}
