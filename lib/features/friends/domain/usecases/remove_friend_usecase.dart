import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/features/friends/domain/repositories/friend_repository.dart';

final removeFriendUseCaseProvider = Provider<RemoveFriendUseCase>((ref) {
  throw UnimplementedError('RemoveFriendUseCase provider needs repository');
});

class RemoveFriendUseCase {
  final FriendRepository _repository;

  RemoveFriendUseCase(this._repository);

  Future<bool> call(String friendId) async {
    return _repository.removeFriend(friendId);
  }
}
