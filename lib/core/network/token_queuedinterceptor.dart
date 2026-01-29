import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:locket/core/config/token.dart';

base class TokenQueuedinterceptor extends QueuedInterceptor {
  final Dio _dio;
  final Token _token;
  final FlutterSecureStorage _storage;
  TokenQueuedinterceptor(this._dio, this._token, this._storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.extra['skipAuth'] == true) return handler.next(options);

    final accessToken = _token.accessToken;
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        err.response?.data['message'] == 'unauthorized') {
      try {
        final refreshToken = _token.refreshToken;
        if (refreshToken != null) {
          return handler.next(err);
        }

        const path = '/auth/refresh';
        final response = await _dio.post(path);
        final accessToken = response.data['accessToken'];
        _token.accessToken = accessToken;
        await _storage.write(key: 'accessToken', value: accessToken);

        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer $accessToken';

        final realResponse = await _dio.fetch(options);
        return handler.resolve(realResponse);
      } catch (e) {
        print(e);
        return handler.next(err);
      }
    }
  }
}
