import 'dart:async';

import 'package:locket/features/users/domain/entities/profile.dart';
import 'package:locket/features/users/domain/repositories/profile_repository.dart';

base class GetProfileUseCase {
  final ProfileRepository _profileRepository;
  const GetProfileUseCase(this._profileRepository);

  FutureOr<Profile?> call() async {
    return await _profileRepository.getProfile();
  }
}
