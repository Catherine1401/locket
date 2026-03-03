import 'package:locket/features/friends/domain/entities/friend.dart';
import 'package:locket/features/friends/domain/repositories/friend_repository.dart';

final class GetFriendsUseCase {
  final FriendRepository _repository;
  GetFriendsUseCase(this._repository);

  Future<List<Friend>> call() => _repository.getFriends();
}
