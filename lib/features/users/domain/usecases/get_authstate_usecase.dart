import 'package:locket/features/users/domain/repositories/auth_repository.dart';

base class GetAuthStateUsecase {
  final AuthRepository _authRepository;
  const GetAuthStateUsecase(this._authRepository);

  Stream<bool> call() async* {
    try {
      yield* _authRepository.authStateChanges();
    } catch (e) {
      print("error from getAuthStateUsecase: $e");
      yield false;
    }
  }
}
