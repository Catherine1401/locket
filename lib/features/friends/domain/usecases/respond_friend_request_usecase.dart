import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/features/friends/domain/repositories/friend_repository.dart';

final respondFriendRequestUseCaseProvider = Provider<RespondFriendRequestUseCase>((ref) {
  // Lấy repository từ injection
  throw UnimplementedError('RespondFriendRequestUseCase provider needs repository');
});

class RespondFriendRequestUseCase {
  final FriendRepository _repository;

  RespondFriendRequestUseCase(this._repository);

  Future<bool> call(String requestId, String status) async {
    return _repository.respondFriendRequest(requestId, status);
  }
}
