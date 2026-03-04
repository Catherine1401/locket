import 'package:locket/features/friends/domain/entities/friend_request.dart';
import 'package:locket/features/friends/domain/repositories/friend_repository.dart';

class GetOutgoingRequestsUseCase {
  final FriendRepository _repository;

  GetOutgoingRequestsUseCase(this._repository);

  Future<List<FriendRequest>> call() async {
    return _repository.getOutgoingRequests();
  }
}
