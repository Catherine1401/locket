import 'dart:async';

import 'package:locket/core/config/token.dart';

abstract interface class AuthDatasource {
  Future<String> getGoogleTokenId();
  FutureOr<Token?> saveToken(Token token);
  Future<void> clearToken();
}
