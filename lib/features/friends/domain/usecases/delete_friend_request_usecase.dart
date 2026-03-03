import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/features/friends/domain/repositories/friend_repository.dart';

final deleteFriendRequestUseCaseProvider = Provider<DeleteFriendRequestUseCase>((ref) {
  throw UnimplementedError('DeleteFriendRequestUseCase provider needs repository');
});

class DeleteFriendRequestUseCase {
  final FriendRepository _repository;

  DeleteFriendRequestUseCase(this._repository);

  Future<bool> call(String requestId) async {
    return _repository.deleteFriendRequest(requestId);
  }
}
