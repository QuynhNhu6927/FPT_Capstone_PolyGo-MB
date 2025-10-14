import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/config/api_constants.dart';
import '../models/api_response.dart';
import '../models/subscription/subscription_plan_list_response.dart';

class SubscriptionService {
  final ApiClient apiClient;

  SubscriptionService(this.apiClient);

  Future<ApiResponse<SubscriptionPlanListResponse>> getSubscriptionPlans({
    required String token,
    int pageNumber = 1,
    int pageSize = 10,
    String? lang,
  }) async {
    try {
      final query = {
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
        if (lang != null) 'lang': lang,
      };

      final response = await apiClient.get(
        ApiConstants.subscriptionPlans,
        queryParameters: query,
        headers: {
          ApiConstants.headerAuthorization: 'Bearer $token',
        },
      );

      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
            (data) => SubscriptionPlanListResponse.fromJson(json),
      );
    } on DioError catch (e) {
      if (e.response != null) {
        print('Get subscription plans error: ${e.response?.data}');
      }
      rethrow;
    }
  }
}
