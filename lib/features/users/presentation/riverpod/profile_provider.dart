import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:locket/features/users/domain/entities/profile.dart';
import 'package:locket/features/users/injection.dart';
import 'package:locket/features/users/presentation/riverpod/auth_state_provider.dart';

final profileProvider = AsyncNotifierProvider<ProfileNotifier, Profile?>(
  () => ProfileNotifier(),
);

base class ProfileNotifier extends AsyncNotifier<Profile?> {
  @override
  FutureOr<Profile?> build() async {
    final profileProvider = await ref.read(getProfileUseCaseProvider.future);
    await ref.watch(authStateProvider.future);
    final profile = await profileProvider.call();
    return profile;
  }

  Future<void> logout() async {
    print("=== Bắt đầu Logout ===");
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      print("--- Đang gọi SignoutUseCase ---");
      final signoutUseCase = await ref.read(signoutUseCaseProvider.future);
      print("--- Gọi API Logout ---");

      await signoutUseCase.call();
      print("--- Gọi API Logout thành công ---");

      return null;
    });

    if (state.hasError) {
      print("Lỗi tìm thấy trong state: ${state.error}");
      print("Chi tiết: ${state.stackTrace}");
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    final currentUser = state.value;
    state = AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final updateDisplayNameUseCase = await ref.read(
        updateDisplayNameUseCaseProvider.future,
      );

      await updateDisplayNameUseCase.call(displayName);

      return currentUser?.copyWith(displayName: displayName);
    });

    print(
      '[debug] Sau khi update: ${state.value?.displayName} (Hash: ${state.value?.hashCode})',
    );
  }

  Future<void> updateAvatar() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return;

    final currentUser = state.value;
    state = AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final updateAvatarUseCase = await ref.read(
        updateAvatarUseCaseProvider.future,
      );
      final newAvatarUrl = await updateAvatarUseCase.call(image.path);
      if (newAvatarUrl == null) return currentUser;
      return currentUser?.copyWith(avatarUrl: newAvatarUrl);
    });
  }
}

