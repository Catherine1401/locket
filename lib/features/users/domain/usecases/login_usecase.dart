import 'dart:async';

import 'package:locket/core/config/token.dart';
import 'package:locket/features/users/domain/repositories/auth_repository.dart';

final class LoginUseCase {
  final AuthRepository _authRepository;
  const LoginUseCase(this._authRepository);

  FutureOr<Token?> call() async {
    try {
      return await _authRepository.loginWithGoogle();
    } catch (e) {
      print("error from loginWithGoogle: $e");
      return null;
    }
  }
}

