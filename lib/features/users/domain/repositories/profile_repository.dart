import 'dart:async';

import 'package:locket/features/users/domain/entities/profile.dart';

abstract interface class ProfileRepository {
  FutureOr<Profile?> getProfile();
  Future<void> updateDisplayName(String displayName);
  Future<String?> updateBirthday(String birthday);
  Future<String?> updateAvatar(String filePath);
}

