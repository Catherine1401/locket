import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:locket/core/config/token.dart';
import 'package:locket/features/users/data/datasources/remote/auth_datasource.dart';

base class AuthDataSourceImpl implements AuthDatasource {
  final GoogleSignIn _google;
  final FlutterSecureStorage _storage;
  const AuthDataSourceImpl(this._google, this._storage);

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
  Future<void> saveToken(Token token) async{
    await _storage.write(key: 'accessToken', value: token.accessToken);
    await _storage.write(key: 'refreshToken', value: token.refreshToken);
  }
}
