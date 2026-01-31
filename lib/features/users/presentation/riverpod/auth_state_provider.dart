import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/features/users/injection.dart';

final authStateProvider = StreamProvider<bool>((ref) async* {
  final getTokenUsecse = await ref.read(getTokenUseCaseProvider).value;
  if (getTokenUsecse == null) {
    yield false;
  } else {
    final token = await getTokenUsecse.call();
    if (token == null) {
      yield false;
    } else if (token.refreshToken == null) {
      yield false;
    } else {
      yield true;
    }
  }

  final getAuthStateUsecase = await ref.read(getAuthStateUseCaseProvider).value;
  if (getAuthStateUsecase == null) {
    yield false;
  } else {
    yield* getAuthStateUsecase.call();
  }
});

base class AuthStateNotifier extends StreamNotifier<bool> {
  @override
  Stream<bool> build() async* {
    final getTokenUseCase = ref.read(getTokenUseCaseProvider).value;
    final token = await getTokenUseCase?.call();
    yield token?.refreshToken == null ? false : true;
    final getAuthStateUseCase = ref.read(getAuthStateUseCaseProvider).value;
    if (getAuthStateUseCase != null) {
      yield* getAuthStateUseCase.call();
    } else {
      yield false;
    }
  }
}
