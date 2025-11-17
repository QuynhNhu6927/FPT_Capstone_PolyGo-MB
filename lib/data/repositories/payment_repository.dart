import '../models/api_response.dart';
import '../models/payment/cancel_deposit_model.dart';
import '../models/payment/deposit_model.dart';
import '../services/apis/payment_service.dart';

class PaymentRepository {
  final PaymentService _service;

  PaymentRepository(this._service);

  Future<ApiResponse<DepositUrlResponse>> getDepositUrl({
    required String token,
    required DepositUrlRequest request,
  }) async {
    try {
      return await _service.getDepositUrl(
        token: token,
        request: request,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<CancelDepositResponse>> cancelDeposit({
    required String token,
    required CancelDepositRequest request,
  }) async {
    try {
      return await _service.cancelDeposit(
        token: token,
        request: request,
      );
    } catch (e) {
      rethrow;
    }
  }
}
