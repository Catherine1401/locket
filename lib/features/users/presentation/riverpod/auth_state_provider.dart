import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/features/users/injection.dart';

final authStateProvider = StreamNotifierProvider<AuthStateNotifier, bool>(
  () => AuthStateNotifier(),
);

base class AuthStateNotifier extends StreamNotifier<bool> {
  @override
  Stream<bool> build() async* {
    final getTokenUseCase = await ref.read(getTokenUseCaseProvider.future);
    final token = await getTokenUseCase.call();
    if (token == null) {
      yield false;
    } else {
      yield true;
    }

    final getAuthStateUseCase = await ref.read(
      getAuthStateUseCaseProvider.future,
    );
    yield* getAuthStateUseCase.call();

  }

  Future<void> login() async {
    final loginUseCase = await ref.read(loginUseCaseProvider.future);
    await loginUseCase.call();  
  }
}
