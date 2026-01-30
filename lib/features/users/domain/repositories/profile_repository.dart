import 'dart:async';

import 'package:locket/features/users/domain/entities/profile.dart';

abstract interface class ProfileRepository {
  FutureOr<Profile?> getProfile();
}
