import 'package:locket/features/users/domain/repositories/auth_repository.dart';

base class GetAuthStateUsecase {
  final AuthRepository _authRepository;
  const GetAuthStateUsecase(this._authRepository);

  Stream<bool> call() {
    return _authRepository.authStateChanges();
  }
}
