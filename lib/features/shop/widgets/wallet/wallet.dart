import 'package:flutter/material.dart';
import '../../../../data/models/transaction/wallet_info_response.dart';
import '../deposit/deposit_dialog.dart';
import 'my_wallet.dart';
import 'transaction_history.dart';
import '../../../../data/models/transaction/wallet_transaction_model.dart';
import '../../../../data/repositories/transaction_repository.dart';
import '../../../../data/services/apis/transaction_service.dart';
import '../../../../core/api/api_client.dart';
import '../../../shared/app_error_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/responsive.dart';

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
  double _pendingBalance = 0;
  List<WalletTransaction> _transactions = [];
  bool _loading = true;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasNextPage = false;
  bool _hasPreviousPage = false;
  List<WalletAccount> _walletAccounts = [];

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

    final wallet = await TransactionRepository(TransactionService(ApiClient())).getWalletInfo(token: token);
    if (!mounted) return;
    setState(() {
      _balance = wallet!.balance;
      _pendingBalance = wallet.pendingBalance;
      _walletAccounts = wallet.accounts;
    });
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception("Token not found");

    final repo = TransactionRepository(TransactionService(ApiClient()));
    final response = await repo.getWalletTransactions(token: token, pageNumber: _currentPage, pageSize: 10);

    if (!mounted) return;
    setState(() {
      _transactions = response?.items ?? [];
      _currentPage = response?.currentPage ?? 1;
      _totalPages = response?.totalPages ?? 1;
      _hasNextPage = response?.hasNextPage ?? false;
      _hasPreviousPage = response?.hasPreviousPage ?? false;
      _loading = false;
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _loading = true;
    });
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return AppErrorState(onRetry: _loadData);

    final walletWidget = MyWallet(
      balance: _balance,
      pendingBalance: _pendingBalance,
      balanceHidden: _balanceHidden,
      accounts: _walletAccounts,
      toggleBalance: () => setState(() => _balanceHidden = !_balanceHidden),
      onDeposit: () {
        showDialog(context: context, builder: (_) => DepositDialog(onDepositSuccess: _loadData));
      },

    );

    final transactionWidget = TransactionHistory(
      transactions: _transactions,
      balanceHidden: _balanceHidden,
      currentBalance: _balance,
      currentPage: _currentPage,
      totalPages: _totalPages,
      hasNextPage: _hasNextPage,
      hasPreviousPage: _hasPreviousPage,
      onPageChanged: _onPageChanged,
      onInquirySuccess: (txId) {
        setState(() {
          final tx = _transactions.firstWhere((t) => t.id == txId);
          tx.isInquiry = true;
        });
      },
    );

    if (isTablet) {
      return Padding(
        padding: EdgeInsets.all(sw(context, 16)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: walletWidget),
            SizedBox(width: sw(context, 16)),
            Expanded(flex: 3, child: transactionWidget),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: sw(context, 16), vertical: sw(context, 16)),
        children: [
          walletWidget,
          SizedBox(height: sw(context, 24)),
          transactionWidget,
        ],
      ),
    );
  }
}
