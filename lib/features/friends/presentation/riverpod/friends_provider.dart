import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/features/friends/domain/entities/friend.dart';
import 'package:locket/features/friends/injection.dart';

final friendsProvider =
    AsyncNotifierProvider<FriendsNotifier, List<Friend>>(FriendsNotifier.new);

final class FriendsNotifier extends AsyncNotifier<List<Friend>> {
  @override
  FutureOr<List<Friend>> build() async {
    final useCase = await ref.read(getFriendsUseCaseProvider.future);
    return useCase.call();
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = await ref.read(getFriendsUseCaseProvider.future);
      return useCase.call();
    });
  }
}
