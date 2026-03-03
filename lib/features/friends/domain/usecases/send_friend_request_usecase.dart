import 'package:locket/features/friends/domain/repositories/friend_repository.dart';

final class SendFriendRequestUsecase {
  final FriendRepository _repository;
  SendFriendRequestUsecase(this._repository);

  Future<bool> call(String targetUserId) =>
      _repository.sendFriendRequest(targetUserId);
}
