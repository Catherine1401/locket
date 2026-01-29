import 'dart:async';

import 'package:dio/dio.dart';
import 'package:locket/core/config/token.dart';
import 'package:locket/features/users/data/datasources/remote/auth_datasource.dart';
import 'package:locket/features/users/domain/repositories/auth_repository.dart';

base class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final AuthDatasource _authDatasource;
  final Token _token;
  const AuthRepositoryImpl(this._dio, this._authDatasource, this._token);

  @override
  FutureOr<Token?> loginWithGoogle() async {
    const path = '/auth/google';
    try {
      final idToken = await _authDatasource.getGoogleTokenId();
      if (idToken == "") return null;

      final response = await _dio.post(path, data: {'idToken': idToken});

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

      _token.accessToken = accessToken;
      _token.refreshToken = refreshToken;

      await _authDatasource.saveToken(_token);

      return _token;
    } catch (e) {
      print("error from loginWithGoogle: $e");
      return null;
    }
  }

  @override
  FutureOr<Token?> refreshToken() {
    // TODO: implement refreshToken
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() {
    // TODO: implement signOut
    throw UnimplementedError();
  }
}
