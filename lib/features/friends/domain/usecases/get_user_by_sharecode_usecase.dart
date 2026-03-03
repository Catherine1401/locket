import 'package:locket/features/friends/domain/repositories/friend_repository.dart';

final class GetUserByShareCodeUsecase {
  final FriendRepository _repository;
  GetUserByShareCodeUsecase(this._repository);

  Future<Map<String, dynamic>?> call(String shareCode) =>
      _repository.getUserByShareCode(shareCode);
}
