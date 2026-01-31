import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:locket/core/config/token.dart';
import 'package:locket/features/users/data/datasources/remote/auth_datasource.dart';

base class AuthDataSourceImpl implements AuthDatasource {
  final GoogleSignIn _google;
  final FlutterSecureStorage _storage;
  final Token _token;
  final Dio _dio;
  const AuthDataSourceImpl(this._google, this._storage, this._token, this._dio);

  @override
  Future<String> getGoogleTokenId() async {
    try {
      final bool canAuthenicate = _google.supportsAuthenticate();
      if (!canAuthenicate) return '';

      final account = await _google.authenticate();
      final auth = account.authentication;

      final String? idToken = auth.idToken;
      if (idToken == null) return '';

      print("idtoken from getGoogleTokenId: $idToken");
      return idToken;
    } catch (e) {
      print("Error from getGoogleTokenId: $e");
      return '';
    }
  }

  @override
  FutureOr<Token?> saveToken(Token token) async {
    await _storage.write(key: 'accessToken', value: token.accessToken);
    await _storage.write(key: 'refreshToken', value: token.refreshToken);
    _token.accessToken = token.accessToken;
    _token.refreshToken = token.refreshToken;
    return _token;
  }

  @override
  Future<void> clearToken() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
    _token.accessToken = null;
    _token.refreshToken = null;
  }

  @override
  FutureOr<Token?> getToken() {
    return _token;
  }

  @override
  FutureOr<Token?> getTokenByRefreshToken() async  {
    final refreshToken = await _storage.read(key: 'refreshToken');
    if (refreshToken == null) return null;

    const path = '/auth/refresh';
    final response = await _dio.post(path, data: {'refreshToken': refreshToken});
    if (response.statusCode != 200) return null;
    print("data from getTokenByRefreshToken: ${response.data}");

    final accessToken = response.data['accessToken'];
    await _storage.write(key: 'accessToken', value: accessToken);
    _token.accessToken = accessToken;
    return _token;
  }

}
