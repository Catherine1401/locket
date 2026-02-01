import 'dart:async';

import 'package:locket/core/config/token.dart';

abstract interface class AuthRepository {
  FutureOr<Token?> loginWithGoogle();
  FutureOr<Token?> refreshToken();
  Future<void> signOut();
  Stream<bool> authStateChanges();
  FutureOr<Token?> getToken();
}
