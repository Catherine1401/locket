import 'package:locket/features/users/domain/repositories/auth_repository.dart';

base class SignoutUseCase {
  final AuthRepository _authRepository;
  const SignoutUseCase(this._authRepository);

  Future<void> call() async {
    try {
      print("--- Đang gọi SignoutUseCase ---");
      await _authRepository.signOut();
      print("--- Gọi API Logout ---");
    } catch (e) {
      print("error from signoutUseCase: $e");
    }
  }
}
