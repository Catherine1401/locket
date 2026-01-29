import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/features/users/injection.dart';

final loginProvider = AsyncNotifierProvider<LoginNotifier, bool>(
  () => LoginNotifier(),
);

class LoginNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    return false;
  }

  Future<void> login() async {
    print("from login provider");
    state = const AsyncValue.loading();
    print("from login provider 2");
    state = await AsyncValue.guard<bool>(() async {
      print("inside process login");
      try {
        final loginUsecase = await ref.read(loginUseCaseProvider.future);
        final login = await loginUsecase.loginWithGoogle();
        if (login == null) {
          return false;
        }
        print("from login: $loginUsecase");
        return true;
      } catch (e) {
        print("error from login: $e");
        return false;
      }
    });
    print("from login provider 3");
  }
}
