import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/features/users/domain/entities/profile.dart';
import 'package:locket/features/users/injection.dart';

final profileProvider = AsyncNotifierProvider<ProfileNotifier, Profile>(
  () => ProfileNotifier(),
);

base class ProfileNotifier extends AsyncNotifier<Profile> {
  @override
  FutureOr<Profile> build() {
    return Profile(
      id: '123',
      email: 'test@test.com',
      displayName: 'test',
      avatarUrl: 'https://avatars.githubusercontent.com/u/135643?v=4',
      birthday: '2000-01-01',
    );
  }

  Future<void> logout() async {
    print("=== Bắt đầu Logout ==="); // In ngoài guard để chắc chắn thấy
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      print("--- Đang gọi SignoutUseCase ---");
      final signoutUseCase = await ref.read(signoutUseCaseProvider.future);
      print("--- Gọi API Logout ---");

      await signoutUseCase.call();
      print("--- Gọi API Logout thành công ---");

      return Profile(
        id: '1',
        email: 'test@test.com',
        displayName: 'test',
        avatarUrl: '',
        birthday: '',
      );
    });

    // Sau khi guard xong, hãy kiểm tra state xem có lỗi không
    if (state.hasError) {
      print("Lỗi tìm thấy trong state: ${state.error}");
      print("Chi tiết: ${state.stackTrace}");
    }
  }
}
