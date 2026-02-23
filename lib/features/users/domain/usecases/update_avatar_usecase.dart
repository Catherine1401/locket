import 'package:locket/features/users/domain/repositories/profile_repository.dart';

final class UpdateAvatarUsecase {
  final ProfileRepository _profileRepository;
  UpdateAvatarUsecase(this._profileRepository);

  Future<String?> call(String filePath) async {
    return await _profileRepository.updateAvatar(filePath);
  }
}
