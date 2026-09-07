import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../storage/secure_storage.dart';
import 'api_endpoints.dart';

/// Wraps [Dio] with auth/locale headers and a single 401 hook the app
/// wires up once a router is available (see [onUnauthorized]).
class ApiClient {
  late final Dio _dio;
  final SecureStorage _storage;

  /// Invoked whenever the API responds with 401 so the app can clear
  /// session state and redirect to the login screen.
  VoidCallback? onUnauthorized;

  ApiClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: const {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final locale = await _storage.readLocale();
          options.headers['Accept-Language'] = locale;

          final token = await _storage.readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          compact: true,
        ),
      );
    }
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) =>
      _dio.get(path, queryParameters: queryParams);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  Future<Response> delete(String path, {dynamic data}) =>
      _dio.delete(path, data: data);

  Future<Response> postFormData(String path, FormData formData) =>
      _dio.post(path, data: formData);

  Future<Response> putFormData(String path, FormData formData) =>
      _dio.put(path, data: formData);
}
