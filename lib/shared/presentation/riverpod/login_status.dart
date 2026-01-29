import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/core/injection.dart';

final loginStatusProvider = AsyncNotifierProvider<LoginStatusNotifier, bool>(
  () => LoginStatusNotifier(),
);

base class LoginStatusNotifier extends AsyncNotifier<bool> {
  @override
  FutureOr<bool> build() async {
    final token = await ref.watch(tokenProvider.future);
    print("token: ${token.toString()}");
    return token.refreshToken != null;
  }
}
