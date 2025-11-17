import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/repositories/payment_repository.dart';
import '../../../../data/services/apis/payment_service.dart';
import '../../../../core/api/api_client.dart';
import '../../../../data/models/payment/cancel_deposit_model.dart';

class PaymentWebView extends StatefulWidget {
  final String url;
  final String returnUrl;
  final String cancelUrl;
  final int orderCode;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onPaymentCancel;

  const PaymentWebView({
    super.key,
    required this.url,
    required this.returnUrl,
    required this.cancelUrl,
    required this.orderCode,
    this.onPaymentSuccess,
    this.onPaymentCancel,
  });

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) async {
            if (!mounted) return;

            if (url.startsWith(widget.returnUrl)) {
              Navigator.pop(context);
              widget.onPaymentSuccess?.call();
            } else if (url.startsWith(widget.cancelUrl)) {
              await _cancelDeposit();
              Navigator.pop(context);
              widget.onPaymentCancel?.call();
            }
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _cancelDeposit() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final repository = PaymentRepository(PaymentService(ApiClient()));
    try {
      await repository.cancelDeposit(
        token: token,
        request: CancelDepositRequest(orderCode: widget.orderCode),
      );
    } catch (e) {
      print("Cancel deposit failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_loading)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
