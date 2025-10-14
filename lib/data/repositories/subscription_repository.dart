import '../models/subscription/subscription_plan_list_response.dart';
import '../services/subscription_service.dart';

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
}
