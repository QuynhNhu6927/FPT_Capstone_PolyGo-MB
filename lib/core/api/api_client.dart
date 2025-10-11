import 'package:dio/dio.dart';
import '../config/api_constants.dart';

class ApiClient {
  final Dio dio;

  ApiClient({Dio? dio})
      : dio = dio ?? Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      ApiConstants.headerContentType: ApiConstants.contentTypeJson,
    },
  )) {

    this.dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // print('--> ${options.method} ${options.uri}');
        // print('Headers: ${options.headers}');
        // print('Body: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // print('<-- ${response.statusCode} ${response.requestOptions.uri}');
        return handler.next(response);
      },
      onError: (DioError e, handler) {
        // print('*** DioError: ${e.message}');
        return handler.next(e);
      },
    ));
  }

  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters, Map<String, String>? headers}) async {
    return await dio.get(endpoint, queryParameters: queryParameters, options: Options(headers: headers));
  }

  Future<Response> post(String endpoint, {dynamic data, Map<String, String>? headers}) async {
    return await dio.post(endpoint, data: data, options: Options(headers: headers));
  }

  Future<Response> put(String endpoint, {dynamic data, Map<String, String>? headers}) async {
    return await dio.put(endpoint, data: data, options: Options(headers: headers));
  }

  Future<Response> delete(String endpoint, {Map<String, dynamic>? queryParameters, Map<String, String>? headers}) async {
    return await dio.delete(endpoint, queryParameters: queryParameters, options: Options(headers: headers));
  }
}
