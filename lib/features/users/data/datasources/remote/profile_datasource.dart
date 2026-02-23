import 'dart:async';

import 'package:locket/features/users/domain/entities/profile.dart';

abstract interface class ProfileDatasource {
  FutureOr<Profile?> getProfile();
  Future<void> updateDisplayName(String displayName);
  Future<void> updateBirthday(String birthday);
  Future<String?> updateAvatar(String filePath);
}

