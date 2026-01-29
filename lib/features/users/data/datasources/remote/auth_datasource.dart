import 'package:locket/core/config/token.dart';

abstract interface class AuthDatasource {
  Future<String> getGoogleTokenId();
  Future<void> saveToken(Token token);
}
