import 'package:locket/features/friends/domain/entities/friend_request.dart';
import 'package:locket/features/friends/domain/repositories/friend_repository.dart';

class GetIncomingRequestsUseCase {
  final FriendRepository _repository;

  GetIncomingRequestsUseCase(this._repository);

  Future<List<FriendRequest>> call() async {
    return _repository.getIncomingRequests();
  }
}
