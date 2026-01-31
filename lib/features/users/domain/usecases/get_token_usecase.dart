import 'package:locket/core/config/token.dart';
import 'package:locket/features/users/domain/repositories/auth_repository.dart';

base class GetTokenUseCase {
  final AuthRepository _authRepository;
  const GetTokenUseCase(this._authRepository);

  Future<Token?> call() async {
    try {
      return await _authRepository.refreshToken();
    } catch (e) {
      print("error from getTokenUseCase: $e");
      return null;
    }
  }
}
