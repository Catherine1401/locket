import 'dart:async';

import 'package:dio/dio.dart';
import 'package:locket/core/config/token.dart';
import 'package:locket/features/users/data/datasources/remote/auth_datasource.dart';
import 'package:locket/features/users/domain/repositories/auth_repository.dart';

base class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final AuthDatasource _authDatasource;
  AuthRepositoryImpl(this._dio, this._authDatasource);

  @override
  FutureOr<Token?> loginWithGoogle() async {
    const path = '/auth/google';
    try {
      final idToken = await _authDatasource.getGoogleTokenId();
      if (idToken == "") return null;

      final response = await _dio.post(
        path,
        data: {'idToken': idToken},
        options: Options(extra: {'skipAuth': true}),
      );

      if (response.statusCode != 200) return null;
      print("data from loginWithGoogle: ${response.data}");

      final (accessToken, refreshToken) = switch (response.data) {
        {
          'accessToken': String accessToken,
          'refreshToken': String refreshToken,
        } =>
          (accessToken, refreshToken),
        _ => throw Exception("Invalid response from loginWithGoogle"),
      };

      final token = await _authDatasource.saveToken(
        Token(accessToken: accessToken, refreshToken: refreshToken),
      );

      _authDatasource.emitAuthenicated();
      print("debug !!!!!");

      return token;
    } catch (e) {
      print("error from loginWithGoogle: $e");
      return null;
    }
  }

  @override
  FutureOr<Token?> refreshToken() {
    final token = _authDatasource.getTokenByRefreshToken();
    if (token == null) {
      _authDatasource.emitUnauthenticated();
      return null;
    }
    _authDatasource.emitAuthenicated();
    return token;
  }

  @override
  Future<void> signOut() async {
    final token = await _authDatasource.getToken();

    if (token == null) return;
    const path = '/auth/logout';
    try {
      await _dio.post(path, data: {'refreshToken': token.refreshToken});
      await _authDatasource.clearToken();
      _authDatasource.emitUnauthenticated();
    } catch (e) {
      _authDatasource.emitUnauthenticated();
      return;
    }
  }

  @override
  Stream<bool> authStateChanges() => _authDatasource.authStateChanges();

  @override
  FutureOr<Token?> getToken() async {
    // TODO: implement getToken
    return await _authDatasource.getToken();
  }
}
