import '../models/api_response.dart';
import '../models/subscription/subscription_auto_renew_response.dart';
import '../models/subscription/subscription_cancel_request.dart';
import '../models/subscription/subscription_cancel_response.dart';
import '../models/subscription/subscription_current_response.dart';
import '../models/subscription/subscription_plan_list_response.dart';
import '../models/subscription/subscription_request.dart';
import '../models/subscription/subscription_response.dart';
import '../models/transaction/wallet_transaction_list_response.dart';
import '../services/apis/subscription_service.dart';

class SubscriptionRepository {
  final SubscriptionService _service;

  SubscriptionRepository(this._service);

  Future<SubscriptionPlanListResponse?> getSubscriptionPlans({
    required String token,
    int pageNumber = 1,
    int pageSize = 10,
    String? lang,
  }) async {
    try {
      final res = await _service.getSubscriptionPlans(
        token: token,
        pageNumber: pageNumber,
        pageSize: pageSize,
        lang: lang,
      );
      return res.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<SubscriptionResponse>> subscribe({
    required String token,
    required SubscriptionRequest request,
  }) async {
    try {
      return await _service.subscribe(token: token, request: request);
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<CurrentSubscription>> getCurrentSubscription({
    required String token,
  }) async {
    try {
      return await _service.getCurrentSubscription(token: token);
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<SubscriptionCancelResponse>> cancelSubscription({
    required String token,
    required SubscriptionCancelRequest request,
  }) async {
    try {
      return await _service.cancelSubscription(token: token, request: request);
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<SubscriptionAutoRenewResponse>> updateAutoRenew({
    required String token,
    required bool autoRenew,
  }) async {
    try {
      return await _service.updateAutoRenew(token: token, autoRenew: autoRenew);
    } catch (e) {
      rethrow;
    }
  }

  Future<WalletTransactionListResponse?> getWalletTransactions({
    required String token,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final res = await _service.getWalletTransactions(
        token: token,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
      return res.data;
    } catch (e) {
      rethrow;
    }
  }

}
