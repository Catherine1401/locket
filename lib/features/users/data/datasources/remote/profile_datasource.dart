import 'dart:async';

import 'package:locket/features/users/domain/entities/profile.dart';

abstract interface class ProfileDatasource {
  FutureOr<Profile?> getProfile();
}
