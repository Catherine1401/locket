import 'package:locket/features/users/domain/repositories/profile_repository.dart';

final class UpdateDisplaynameUsecase {
  final ProfileRepository _profileRepository;
  UpdateDisplaynameUsecase(this._profileRepository);

  Future<void> call(String displayName) async {
    await _profileRepository.updateDisplayName(displayName);
  }
}
