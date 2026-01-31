import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/features/users/domain/entities/profile.dart';
import 'package:locket/features/users/injection.dart';

final profileProvider = AsyncNotifierProvider<ProfileNotifier, Profile?>(
  () => ProfileNotifier(),
);

base class ProfileNotifier extends AsyncNotifier<Profile?> {
  @override
  FutureOr<Profile?> build() async {
    final profileProvider = await ref.read(getProfileUseCaseProvider.future);
    final profile = await profileProvider.call();
    return profile;
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

  Future<void> updateDisplayName(String displayName) async {
    // 1. Lấy giá trị hiện tại ngay lập tức
    final currentUser = state.value;
    state = AsyncValue.loading();

    // 2. Sử dụng guard nhưng trả về đối tượng đã copy từ biến currentUser
    state = await AsyncValue.guard(() async {
      final updateDisplayNameUseCase = await ref.read(
        updateDisplayNameUseCaseProvider.future,
      );

      await updateDisplayNameUseCase.call(displayName);

      // Trả về bản copy từ currentUser đã lưu, không dùng state.value ở đây
      return currentUser?.copyWith(displayName: displayName);
    });

    print(
      '[debug] Sau khi update: ${state.value?.displayName} (Hash: ${state.value?.hashCode})',
    );
  }
}
