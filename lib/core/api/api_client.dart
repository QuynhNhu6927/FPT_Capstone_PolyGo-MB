import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_constants.dart';

class ApiClient {
  final Dio dio;

  ApiClient({Dio? dio})
      : dio = dio ??
      Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
        },
      )) {
    this.dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('--> ${options.method} ${options.uri}');
        debugPrint('Headers: ${options.headers}');
        debugPrint('Body: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('<-- ${response.statusCode} ${response.requestOptions.uri}');
        debugPrint('Response: ${response.data}');
        return handler.next(response);
      },
      onError: (DioError e, handler) {
        debugPrint('*** DioError ***');
        debugPrint('Message: ${e.message}');
        debugPrint('Type: ${e.type}');
        if (e.response != null) {
          debugPrint('Status: ${e.response?.statusCode}');
          debugPrint('Data: ${e.response?.data}');
        } else {
          debugPrint('No response received (network issue?)');
        }
        return handler.next(e);
      },
    ));
  }

  Future<Response> get(String endpoint,
      {Map<String, dynamic>? queryParameters, Map<String, String>? headers}) async {
    return await dio.get(endpoint,
        queryParameters: queryParameters, options: Options(headers: headers));
  }

  Future<Response> post(String endpoint,
      {dynamic data, Map<String, String>? headers}) async {
    return await dio.post(endpoint, data: data, options: Options(headers: headers));
  }

  Future<Response> put(String endpoint,
      {dynamic data, Map<String, String>? headers}) async {
    return await dio.put(endpoint, data: data, options: Options(headers: headers));
  }

  Future<Response> delete(String endpoint,
      {dynamic data, Map<String, dynamic>? queryParameters, Map<String, String>? headers}) async {
    return await dio.delete(endpoint,
        data: data, queryParameters: queryParameters, options: Options(headers: headers));
  }
}
