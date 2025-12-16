import '../models/transaction/add_bank_request.dart';
import '../models/transaction/send_inquiry_model.dart';
import '../models/transaction/wallet_info_response.dart';
import '../models/transaction/wallet_transaction_model.dart';
import '../models/transaction/withdraw_confirm_request.dart';
import '../models/transaction/withdraw_request_model.dart';
import '../services/apis/transaction_service.dart';

class TransactionRepository {
  final TransactionService _service;

  TransactionRepository(this._service);

  Future<WalletInfoResponse?> getWalletInfo({required String token}) async {
    final res = await _service.getWalletInfo(token: token);
    return res.data;
  }

  Future<WalletTransactionListResponse?> getWalletTransactions({
    required String token,
    int pageNumber = 1,
    int pageSize = 10,
    String? description,
    String? transactionType,
    String? transactionMethod,
    String? transactionStatus,
    bool? isInquiry,
  }) async {
    try {
      final res = await _service.getWalletTransactions(
        token: token,
        pageNumber: pageNumber,
        pageSize: pageSize,
        description: description,
        transactionType: transactionType,
        transactionMethod: transactionMethod,
        transactionStatus: transactionStatus,
        isInquiry: isInquiry,
      );
      return res.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteBankAccount({
    required String token,
    required String bankAccountId,
  }) async {
    final res = await _service.deleteBankAccount(
      token: token,
      bankAccountId: bankAccountId,
    );

    return res.message == "Success.Delete";
  }

  Future<bool> addBankAccount({
    required String token,
    required AddBankRequest request,
  }) async {
    final res = await _service.addBankAccount(
      token: token,
      request: request,
    );

    return res.message == "Success.Create";
  }

  Future<bool> createWithdrawRequest({
    required String token,
    required WithdrawRequestModel request,
  }) async {
    final res = await _service.createWithdrawRequest(
      token: token,
      request: request,
    );

    return res.message == "Success.RequestWithdrawal";
  }

  Future<bool> confirmWithdrawal({
    required String token,
    required WithdrawConfirmRequest request,
  }) async {
    final res = await _service.confirmWithdrawal(
      token: token,
      request: request,
    );

    return res.message == "Success.ConfirmWithdrawal";
  }

  Future<bool> sendInquiry({
    required String token,
    required String transactionId,
    required SendInquiryRequest request,
  }) async {
    final res = await _service.sendInquiry(
      token: token,
      transactionId: transactionId,
      request: request,
    );

    return res.message == "Success.SendTransactionInquiry";
  }

  Future<WalletTransaction?> getTransactionDetail({
    required String token,
    required String transactionId,
  }) async {
    final res = await _service.getTransactionById(
      token: token,
      transactionId: transactionId,
    );
    return res.data;
  }

}
