// repositories/gift_repository.dart
import '../models/gift/gift_accept_response.dart';
import '../models/gift/gift_list_response.dart';
import '../models/gift/gift_me_response.dart';
import '../models/gift/gift_present_request.dart';
import '../models/gift/gift_present_response.dart';
import '../models/gift/gift_purchase_request.dart';
import '../models/gift/gift_purchase_response.dart';
import '../models/gift/gift_received_response.dart';
import '../services/apis/gift_service.dart';

class GiftRepository {
  final GiftService _service;

  GiftRepository(this._service);

  Future<GiftListResponse?> getGifts({
    required String token,
    int pageNumber = 1,
    int pageSize = 10,
    String? lang,
  }) async {
    try {
      final res = await _service.getGifts(
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

  Future<GiftPurchaseResponse?> purchaseGift({
    required String token,
    required GiftPurchaseRequest request,
  }) async {
    try {
      final res = await _service.purchaseGift(token: token, request: request);
      return res.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<GiftMeResponse?> getMyGifts({
    required String token,
    int pageNumber = 1,
    int pageSize = 10,
    String? lang,
  }) async {
    try {
      final res = await _service.getMyGifts(
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

  Future<GiftPresentResponse?> presentGift({
    required String token,
    required GiftPresentRequest request,
  }) async {
    try {
      final res = await _service.presentGift(token: token, request: request);
      return res.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<GiftReceivedResponse?> getReceivedGifts({
    required String token,
    int pageNumber = 1,
    int pageSize = 10,
    String? lang,
  }) async {
    try {
      final res = await _service.getReceivedGifts(
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

  Future<GiftAcceptResponse?> acceptReceivedGift({
    required String token,
    required String presentationId,
  }) async {
    try {
      final res = await _service.acceptReceivedGift(
        token: token,
        presentationId: presentationId,
      );
      return res.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<GiftAcceptResponse?> rejectReceivedGift({
    required String token,
    required String presentationId,
  }) async {
    try {
      final res = await _service.rejectReceivedGift(
        token: token,
        presentationId: presentationId,
      );
      return res.data;
    } catch (e) {
      rethrow;
    }
  }


}
